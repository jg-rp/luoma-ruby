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

      for_loop = false

      bind_expr = case parser.current_value
                  when "with"
                    parser.next
                    parser.parse_expression
                  when "for"
                    for_loop = true
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
      new(token, tag_name, name, for_loop, bind_expr, bind_name, args)
    end

    #: (t_token, String, Name, bool, Expression?, Name?, Array[KeywordArgument]) -> void
    def initialize(token, tag_name, template_name, for_loop, bind_expression, bind_name, args)
      super(token)
      @tag_name = tag_name
      @template_name = template_name
      @for_loop = for_loop
      @bind_expression = bind_expression
      @bind_name = bind_name
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

      bind_key = @bind_name&.value || template.name.split(".").first
      bind_value = @bind_expression&.evaluate(context) || context.resolve(name)
      scope = @args.to_h { |arg| [arg.name.value, arg.expression.evaluate(context)] }

      ctx = context.copy(
        scope,
        block_scope: false,
        disabled_tags: DISABLED_TAGS,
        template: template
      )

      if @for_loop && bind_value.is_a?(Array)
        for_loop_drop = ForLoopDrop.new(
          bind_key,
          bind_value.length,
          nil
        )

        scope["forloop"] = for_loop_drop

        bind_value.each do |item|
          scope[bind_key] = item
          for_loop_drop.next
          template.render_with_context(ctx, buffer)
        end
      else
        scope[bind_key] = bind_value
        template.render_with_context(ctx, buffer)
      end

      context.render_score_cumulative += ctx.render_score
    end

    #: () -> Array[Expression]
    def expressions
      result = [] #: Array[Expression]
      result << @bind_expression if @bind_expression # steep:ignore
      result.concat(@args.map(&:expression))
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
      scope << (@bind_name || Name.new(@template_name.token, name)) if @bind_expression

      Partial.new(template, :isolated, scope, Luoma.fnv1a32("#{name}-#{scope.map(&:value).join(":")}"))
    end
  end
end
