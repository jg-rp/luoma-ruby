# frozen_string_literal: true

module Luoma
  module Predicates
    #: (RenderContext, untyped) -> bool
    def self.blank?(context, obj)
      case obj
      when nil
        true
      when String
        obj.strip == ""
      when Array, Hash
        obj.empty?
      else
        obj.respond_to?(:length) ? obj.length.zero? : false
      end
    end
  end
end
