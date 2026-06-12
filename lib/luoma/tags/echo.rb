# frozen_string_literal: true

module Luoma
  class EchoTag < Markup
    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      expr = parser.parse_filtered_expression
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      new(token, tag_name, expr)
    end

    def initialize(token, tag_name, expression)
      super(token)
      @tag_name = tag_name
      @expression = expression
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      buffer << context.env.serialize(
        @expression.evaluate(context),
        context,
        @expression.span
      )
    end

    #: () -> Array[Expression]
    def expressions
      [@expression]
    end
  end
end
