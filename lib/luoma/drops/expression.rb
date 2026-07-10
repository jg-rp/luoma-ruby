# frozen_string_literal: true

module Luoma
  class ExpressionDrop < Drop
    attr_reader :expr

    #: (LambdaExpr) -> void
    def initialize(expr)
      super()
      @expr = expr
    end

    #: (:data | :numeric | :string | :boolean, RenderContext) -> untyped
    def to_primitive(hint, context)
      case hint
      when :numeric
        :nothing
      when :data, :string
        render(context)
      when :boolean
        true
      end
    end

    def render(context)
      @expr.to_s
    end
  end
end
