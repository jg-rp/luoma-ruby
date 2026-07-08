# frozen_string_literal: true

module Luoma
  class BlockDrop < Drop
    #: (t_block) -> void
    def initialize(block)
      super()
      @block = block
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
      buf = +""

      context.extends({}) do # For recursive block detection.
        Luoma.render_block(@block, context, buf)
      end

      buf
    end
  end
end
