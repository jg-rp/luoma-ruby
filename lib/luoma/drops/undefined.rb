# frozen_string_literal: true

module Luoma
  attr_reader :path

  # The default and base "undefined" type.
  class UndefinedDrop < Drop
    #: (String, t_token, String, String) -> void
    def initialize(path, token, source, template_name)
      super()
      @path = path
      @token = token
      @source = source
      @template_name = template_name
    end

    #: (String, RenderContext) -> untyped
    def fetch(name, context)
      self
    end

    #: (untyped, RenderContext) -> bool
    def eq?(obj, context)
      obj.nil? || obj.is_a?(UndefinedDrop) || obj.is_a?(BlankDrop)
    end
  end

  # An "undefined" type that raises `UndefinedVariableError` in all contexts.
  class StrictUndefinedDrop < UndefinedDrop
    def key?(obj, context)
      error
    end

    def fetch(name, context)
      error
    end

    def each
      error
    end

    def eq?(obj, context)
      error
    end

    def lt?(obj, context)
      error
    end

    def length(context)
      error
    end

    def slice(offset, limit, reversed)
      error
    end

    def to_primitive(hint, context)
      error
    end

    def to_s
      error
    end

    def to_html_safe_s
      error
    end

    protected

    def error
      raise UndefinedVariableError.new(
        "#{@path.inspect} is undefined",
        @token,
        @source,
        @template_name
      )
    end
  end

  # An "undefined" type that can be tested for truthiness and compared to
  # other objects without raising an error.
  class FalsyStrictUndefinedDrop < StrictUndefinedDrop
    def eq?(obj, context)
      context.env.nothing?(obj)
    end

    def to_primitive(hint, context)
      hint == :boolean ? false : error
    end

    def key?(obj, context)
      false
    end
  end
end
