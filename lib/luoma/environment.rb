# frozen_string_literal: true

module Luoma
  class Environment
    attr_accessor :auto_trim, :globals, :lexer, :loader, :parser, :strict_filters, :suppress_blank_control_flow_blocks,
                  :undefined, :filters, :tags

    # TODO: resource limits

    def initialize(
      auto_trim: nil,
      globals: nil,
      lexer: BaseLexer,
      loader: nil,
      parser: Parser,
      strict_filters: true,
      suppress_blank_control_flow_blocks: true,
      undefined: UndefinedDrop
    )
      @auto_trim = auto_trim
      @globals = globals
      @lexer = lexer
      @loader = loader || HashLoader.new({})
      @parser = parser
      @strict_filters = strict_filters
      @suppress_blank_control_flow_blocks = suppress_blank_control_flow_blocks
      @undefined = undefined

      @tags = {} #: Hash[String, _Tag]
      @filters = {} #: Hash[String, [untyped, Integer?]]

      setup_tags_and_filters
    end

    #: (String,
    #   ?globals: t_namespace?,
    #   ?name: String?,
    #   ?overlay: t_namespace?,
    #   ?up_to_date: Proc::_Callable?) -> Template
    def parse(source, globals: nil, name: nil, overlay: nil, up_to_date: nil)
      raise "TODO:"
    end

    #: (String, ?data: t_namespace?) -> String
    def render(source, data: nil)
      raise "TODO:"
    end

    #: (String, ?globals: t_namespace?, ?context: RenderContext?, **untyped) -> Template
    def get_template(name, globals: nil, context: nil, **kwargs)
      raise "TODO:"
    end

    # Add or replace a filter. The same callable can be registered multiple times with
    # different names.
    #
    # If _callable_ accepts a keyword parameter called `context`, the active render
    # context will be passed to `#call`.
    #
    # @param name [String] The name of the filter, as used by template authors.
    # @param callable [responds to call] An object that responds to `#call(left, ...)`
    #   and `#parameters`. Like a Proc or Method.
    def register_filter(name, callable)
      with_context = callable.parameters.index do |(kind, param)|
        kind == :keyreq && param == :context
      end
      @filters[name] = [callable, with_context]
    end

    # Remove a filter from the filter register.
    # @param name [String] The name of the filter.
    # @return [callable | nil] The callable implementing the removed filter, or nil
    #    if _name_ did not exist in the filter register.
    def delete_filter(name)
      @filters.delete(name)
    end

    # Add or replace a tag.
    # @param name [String] The tag's name, as used by template authors.
    # @param tag [responds to parse: ([Symbol, String?, Integer], Parser) -> Tag]
    def register_tag(name, tag)
      @tags[name] = tag
    end

    # Remove a tag from the tag register.
    # @param name [String] The name of the tag.
    # @return [_Tag | nil]
    def delete_tag(name)
      @tags.delete(name)
    end

    #: () -> void
    def setup_tags_and_filters
      raise "TODO:"
    end

    #: (untyped, untyped, RenderContext, t_token) -> bool
    def contains?(left, right, context, token)
      raise "TODO:"
    end

    #: (untyped, untyped, RenderContext, t_token) -> bool
    def eq?(left, right, context, token)
      raise "TODO:"
    end

    #: (untyped, untyped, RenderContext, t_token) -> bool
    def lt?(left, right, context, token)
      raise "TODO:"
    end

    #: (untyped) -> bool
    def nothing?(obj)
      raise "TODO:"
    end

    #: (untyped, RenderContext) -> bool
    def truthy?(obj, context)
      raise "TODO:"
    end

    #: (untyped, RenderContext, t_token) -> String
    def serialize(obj, context, token)
      raise "TODO:"
    end

    #: (untyped, RenderContext, t_token) -> Array[untyped]
    def to_a(obj, context, token)
      raise "TODO:"
    end

    #: (untyped, RenderContext, t_token) -> Integer
    def to_i(obj, context, token)
      raise "TODO:"
    end

    #: (untyped, RenderContext, t_token) -> String
    def to_string(obj, context, token)
      raise "TODO:"
    end

    #: (String, String?, String?) -> String
    def trim(value, left, right)
      raise "TODO:"
    end

    protected

    #: (t_namespace?) -> t_namespace?
    def make_globals(namespace)
      raise "TODO:"
    end
  end
end
