# frozen_string_literal: true

module Luoma
  class IncludeTag < Markup
    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      name_expr = parser.parse_expression

      # Leading commas are OK
      parser.next if parser.kind == :token_comma

      args = parser.parse_keyword_arguments(require_commas: true)
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      new(token, tag_name, name_expr, args)
    end

    #: (t_token, String, Expression, Array[KeywordArgument]) -> void
    def initialize(token, tag_name, template_name, args)
      super(token)
      @tag_name = tag_name
      @template_name = template_name
      @args = args
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      name = context.env.to_string(@template_name.evaluate(context), context)

      begin
        template = context.env.get_template(
          name,
          context: context,
          tag: "include"
        )
      rescue TemplateNotFoundError => e
        raise NoSuchTemplateError.new(
          e.message,
          @template_name.span,
          context.template.source,
          context.template.name
        )
      end

      scope = @args.to_h { |arg| [arg.name.value, arg.expression.evaluate(context)] }

      context.extends(scope, template: template) do
        template.render_with_context(context, buffer, isolated: false)
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
