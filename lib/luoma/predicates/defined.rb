# frozen_string_literal: true

module Luoma
  module Predicates
    #: (RenderContext, untyped) -> bool
    def self.defined?(context, obj)
      !(obj == :nothing || obj.is_a?(UndefinedDrop))
    end
  end
end
