# frozen_string_literal: true

module Luoma
  module Predicates
    #: (untyped) -> bool
    def self.defined?(value)
      !(value == :nothing || value.is_a?(UndefinedDrop))
    end
  end
end
