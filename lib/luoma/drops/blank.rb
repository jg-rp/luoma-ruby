# frozen_string_literal: true

module Luoma
  class BlankDrop < Drop
    #: (untyped, RenderContext) -> bool
    def eq?(obj, context)
      return false if obj.is_a?(BlankDrop) || obj.is_a?(EmptyDrop)
      return true if obj.nil? || obj == false || obj.is_a?(UndefinedDrop)
      return obj.strip.empty? if obj.is_a?(String)
      return obj.empty? if obj.is_a?(Array) || obj.is_a?(Hash)

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
        false
      end
    end
  end

  BLANK = BlankDrop.new.freeze
end
