# frozen_string_literal: true

module Luoma
  class OutputStatement < Markup
    def initialize(token, expression)
      super(token)
      @expression = expression
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      buffer << context.env.serialize(@expression.evaluate(context), context)
    end

    #: () -> Array[Expression]
    def expressions
      [@expression]
    end
  end
end
