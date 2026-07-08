# frozen_string_literal: true

module Luoma
  class HTMLSafeDrop < Drop
    #: (String | HTMLSafeDrop) -> HTMLSafeDrop
    def self.escape(value)
      value.is_a?(String) ? HTMLSafeDrop.new(Luoma.escape(value)) : value
    end

    #: (String | HTMLSafeDrop) -> HTMLSafeDrop
    def self.from(value)
      value.is_a?(String) ? HTMLSafeDrop.new(value) : value
    end

    #: (String) -> void
    def initialize(s)
      super()
      @s = s
    end

    #: (:data | :numeric | :string | :boolean, RenderContext) -> untyped
    def to_primitive(hint, context)
      case hint
      when :string, :data
        @s
      else
        :nothing
      end
    end

    #: (RenderContext) -> String?
    def render(context)
      @s
    end
  end
end
