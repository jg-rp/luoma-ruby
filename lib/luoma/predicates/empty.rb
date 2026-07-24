# frozen_string_literal: true

module Luoma
  module Predicates
    #: (RenderContext, untyped) -> bool
    def self.empty?(context, obj)
      case obj
      when Array, Hash, String
        obj.empty?
      else
        obj.respond_to?(:length) ? obj.length.zero? : false # rubocop:disable Style/ZeroLengthPredicate
      end
    end
  end
end
