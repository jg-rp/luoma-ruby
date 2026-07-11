# frozen_string_literal: true

module Luoma
  class RenderTag < Markup
    DISABLED_TAGS = Set["include"]

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

      # Leading commas are OK
      parser.next if parser.kind == :token_comma

      args = parser.parse_keyword_arguments(require_commas: false)
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      new(token, tag_name, name, args)
    end

    #: (t_token, String, Name, Array[KeywordArgument]) -> void
    def initialize(token, tag_name, template_name, args)
      super(token)
      @tag_name = tag_name
      @template_name = template_name
      @args = args
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      name = @template_name.value

      begin
        template = context.env.get_template(
          name,
          context: context,
          tag: "render"
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
        disabled_tags: DISABLED_TAGS,
        template: template
      )

      template.render_with_context(ctx, buffer)
      context.render_score_cumulative += ctx.render_score
    end

    #: () -> Array[Expression]
    def expressions
      @args.map(&:expression)
    end

    #: (RenderContext) -> Partial?
    def partial(static_context)
      name = @template_name.value

      template = static_context.env.get_template(
        name,
        context: static_context,
        tag: "render"
      )

      scope = @args.map(&:name)

      Partial.new(
        template,
        :isolated,
        scope,
        Luoma.fnv1a32("#{name}-#{scope.map(&:value).join(":")}")
      )
    end
  end
end
