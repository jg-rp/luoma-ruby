# frozen_string_literal: true

module Luoma
  class EmptyDrop < Drop
    #: (untyped, RenderContext) -> bool
    def eq?(obj, context)
      return true if obj.is_a?(EmptyDrop)
      return obj.empty? if obj.is_a?(Array) || obj.is_a?(Hash) || obj.is_a?(String)

      false
    end

    #: (:data | :numeric | :string | :boolean, RenderContext) -> untyped
    def to_primitive(hint, context)
      case hint
      when :numeric
        0
      when :string, :data
        ""
      when :boolean
        true
      end
    end
  end

  EMPTY = EmptyDrop.new.freeze
end
