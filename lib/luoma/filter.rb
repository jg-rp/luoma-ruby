# frozen_string_literal: true

module Luoma
  class FilterContext
    attr_reader :token, :render_context, :env

    #: (t_token, RenderContext)
    def initialize(token, render_context)
      @token = token
      @render_context = render_context
      @env = render_context.env
    end

    # (String) -> TemplateTypeError
    def type_error(message)
      TemplateTypeError.new(
        message, @token,
        @render_context.template.source,
        @render_context.template.name
      )
    end

    # (String) -> FilterArgumentError
    def argument_error(message)
      FilterArgumentError.new(
        message, @token,
        @render_context.template.source,
        @render_context.template.name
      )
    end

    #: (untyped) -> Array[untyped]
    def to_a(obj)
      @env.to_a(obj, @render_context, @token)
    end

    #: (untyped) -> Integer
    def to_i(obj)
      @env.to_i(obj, @render_context, @token)
    end

    #: (untyped) -> String
    def to_string(obj)
      @env.to_string(obj, @render_context, @token)
    end

    #: (untyped) -> Numeric
    def to_numeric(obj, default: 0)
      @env.to_numeric(obj, default: default)
    end

    #: (untyped) -> Numeric
    def to_decimal(obj, default: 0)
      @env.to_decimal(obj, default: default)
    end

    #: (untyped) -> Enumerable[untyped]
    def to_enumerable(obj)
      @env.to_enumerable(obj)
    end

    #: (untyped) -> untyped
    def to_date(obj)
      @env.to_date(obj)
    end

    #: (untyped) -> bool
    def truthy?(obj)
      @env.truthy?(obj, @render_context)
    end

    #: (untyped) -> bool
    def empty?(obj)
      EMPTY.eq?(obj, @render_context)
    end

    #: (untyped) -> bool
    def nothing?(obj)
      @env.nothing?(obj)
    end

    #: (untyped, untyped, ?default: untyped?) -> untyped
    def fetch(obj, key, default: :nothing)
      raise argument_error("can't read property #{obj}[#{key}]") if nothing?(obj)

      obj[key]
    rescue ArgumentError, TypeError, NoMethodError
      default
    end
  end
end
