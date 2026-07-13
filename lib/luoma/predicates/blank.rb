# frozen_string_literal: true

module Luoma
  module Predicates
    #: (untyped) -> bool
    def self.blank?(value)
      case value
      when nil
        true
      when String
        value.strip == ""
      when Array, Object
        value.empty? # steep:ignore
      else
        value.respond_to?(:length) ? value.length.zero? : false
      end
    end
  end
end
