# frozen_string_literal: true

module Luoma
  module Predicates
    #: (untyped) -> bool
    def self.empty?(value)
      case value
      when Array, Object, String
        value.empty? # steep:ignore
      else
        value.respond_to?(:length) ? value.length.zero? : false
      end
    end
  end
end
