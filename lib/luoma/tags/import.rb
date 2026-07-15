# frozen_string_literal: true

module Luoma
  class ImportTag < Markup
    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      name_expr = parser.parse_string_literal
      name_value = name_expr.value

      unless name_value
        raise TemplateSyntaxError.new(
          "expected a string literal",
          name_expr.span,
          parser.source,
          parser.template_name
        )
      end

      name = Name.new(name_expr.token, name_value)

      namespace = if parser.current_value == "as"
                    parser.next
                    parser.parse_ident
                  end

      # Leading commas are OK
      parser.next if parser.kind == :token_comma

      args = parser.parse_keyword_arguments(require_commas: true)
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      new(token, tag_name, name, namespace, args)
    end

    #: (t_token, String, Name, Name?, Array[KeywordArgument]) -> void
    def initialize(token, tag_name, template_name, namespace, args)
      super(token)
      @tag_name = tag_name
      @template_name = template_name
      @namespace = namespace
      @args = args
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      begin
        template = context.env.get_template(
          @template_name.value,
          context: context,
          tag: "import"
        )
      rescue TemplateNotFoundError => e
        raise NoSuchTemplateError.new(
          e.message,
          @template_name.span,
          context.template.source,
          context.template.name
        )
      end

      ctx = context.copy(
        @args.to_h { |arg| [arg.name.value, arg.expression.evaluate(context)] },
        block_scope: false,
        template: template
      )

      template.render_with_context(ctx, +"") # Discard output.
      context.render_score_cumulative += ctx.render_score

      # Update locals only.
      if @namespace
        context.assign(@namespace.value, ctx.locals) # steep:ignore
      else
        context.locals.update(ctx.locals)
      end
    end

    #: () -> Array[Expression]
    def expressions
      @args.map(&:expression)
    end

    #: (RenderContext) -> Partial?
    def partial(static_context)
      name = static_context.env.to_string(@template_name.evaluate(static_context), static_context)

      template = static_context.env.get_template(
        name,
        context: static_context,
        tag: "include"
      )

      scope = @args.map(&:name)

      Partial.new(
        template,
        :shared,
        scope,
        Luoma.fnv1a32("#{name}-#{scope.map(&:value).join(":")}")
      )
    end
  end
end
