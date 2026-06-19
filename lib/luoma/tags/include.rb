# frozen_string_literal: true

module Luoma
  class IncludeTag < Markup
    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      name_expr = parser.parse_expression

      bind_expr = case parser.current_value
                  when "for", "with"
                    parser.next
                    parser.parse_expression
                  end

      bind_name = if parser.current_value == "as"
                    parser.next
                    parser.parse_ident
                  end

      # Leading commas are OK
      parser.next if parser.kind == :token_comma

      args = parser.parse_keyword_arguments(require_commas: false)
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      new(token, tag_name, name_expr, bind_expr, bind_name, args)
    end

    #: (t_token, String, Expression, Expression?, Name?, Array[KeywordArgument]) -> void
    def initialize(token, tag_name, template_name, bind_expression, bind_name, args)
      super(token)
      @tag_name = tag_name
      @template_name = template_name
      @bind_expression = bind_expression
      @bind_name = bind_name
      @args = args
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      name = context.env.to_string(
        @template_name.evaluate(context),
        context,
        @template_name.token
      )

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

      bind_key = @bind_name&.value || template.name.split(".").first
      bind_value = @bind_expression&.evaluate(context) || context.resolve(name)
      scope = @args.to_h { |arg| [arg.name.value, arg.expression.evaluate(context)] }

      context.extends(scope, template: template) do
        if bind_value.is_a?(Array)
          bind_value.each do |item|
            scope[bind_key] = item
            template.render_with_context(context, buffer)
          end
        else
          scope[bind_key] = bind_value
          template.render_with_context(context, buffer)
        end
      end
    end

    #: () -> Array[Expression]
    def expressions
      result = [@template_name]
      result << @bind_expression if @bind_expression # steep:ignore
      result.concat(@args.map(&:expression))
    end

    #: (RenderContext) -> Partial?
    def partial(static_context)
      name = static_context.env.to_string(
        @template_name.evaluate(static_context),
        static_context,
        @template_name.token
      )

      template = static_context.env.get_template(
        name,
        context: static_context,
        tag: "include"
      )

      scope = @args.map(&:name)
      scope << (@bind_name || Name.new(@template_name.token, name)) if @bind_expression

      Partial.new(template, :shared, scope, Luoma.fnv1a32("#{name}-#{scope.map(&:value).join}"))
    end
  end
end
