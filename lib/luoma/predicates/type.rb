# frozen_string_literal: true

module Luoma
  module Predicates
    #: (RenderContext, untyped) -> bool
    def self.null?(context, obj)
      obj.nil?
    end

    #: (RenderContext, untyped) -> bool
    def self.string?(context, obj)
      obj.is_a?(String)
    end

    #: (RenderContext, untyped) -> bool
    def self.number?(context, obj)
      obj.is_a?(Numeric)
    end

    #: (RenderContext, untyped) -> bool
    def self.array?(context, obj)
      obj.is_a?(Array)
    end

    #: (RenderContext, untyped) -> bool
    def self.object?(context, obj)
      obj.is_a?(Hash)
    end

    #: (RenderContext, untyped) -> bool
    def self.numeric?(context, obj)
      obj.is_a?(Numeric) || (context.env.to_numeric(obj, context) != :nothing)
    end
  end
end
