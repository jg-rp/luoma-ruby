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

      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      new(token, tag_name, name, namespace)
    end

    #: (t_token, String, Name, Name?) -> void
    def initialize(token, tag_name, template_name, namespace)
      super(token)
      @tag_name = tag_name
      @template_name = template_name
      @namespace = namespace
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
        {},
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

    #: (RenderContext) -> Partial?
    def partial(static_context)
      name = static_context.env.to_string(@template_name.evaluate(static_context), static_context)

      template = static_context.env.get_template(
        name,
        context: static_context,
        tag: "import"
      )

      Partial.new(
        template,
        :shared,
        {}, #: untyped
        Luoma.fnv1a32("im[ort-#{name}")
      )
    end
  end
end
