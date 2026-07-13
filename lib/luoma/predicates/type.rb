# frozen_string_literal: true

module Luoma
  module Predicates
    #: (untyped) -> bool
    def self.null?(value)
      value.nil?
    end

    #: (untyped) -> bool
    def self.string?(value)
      value.is_a?(String)
    end

    #: (untyped) -> bool
    def self.number?(value)
      value.is_a?(Numeric)
    end

    #: (untyped) -> bool
    def self.array?(value)
      value.is_a?(Array)
    end

    #: (untyped) -> bool
    def self.object?(value)
      value.is_a?(Hash)
    end
  end
end
