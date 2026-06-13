# frozen_string_literal: true

require "bigdecimal"
require "json"

module Luoma
  class Environment
    attr_reader :persistent_registers

    attr_accessor :auto_escape, :auto_trim, :globals, :lexer, :loader, :parser, :strict_filters,
                  :suppress_blank_control_flow_blocks, :undefined, :filters, :tags, :max_assign_score_cumulative,
                  :max_assign_score, :max_context_depth, :max_render_score_cumulative, :max_render_score,
                  :max_render_size

    def initialize(
      auto_escape: nil,
      auto_trim: nil,
      globals: nil,
      lexer: LegacyLexer,
      loader: nil,
      max_assign_score_cumulative: nil,
      max_assign_score: nil,
      max_context_depth: 30,
      max_render_score_cumulative: nil,
      max_render_score: nil,
      max_render_size: nil,
      parser: LegacyParser,
      strict_filters: true,
      suppress_blank_control_flow_blocks: true,
      undefined: UndefinedDrop
    )
      @auto_escape = auto_escape
      @auto_trim = auto_trim
      @globals = globals
      @lexer = lexer
      @loader = loader || HashLoader.new({})
      @max_assign_score = max_assign_score
      @max_assign_score_cumulative = max_assign_score_cumulative
      @max_context_depth = max_context_depth
      @max_render_score = max_render_score
      @max_render_score_cumulative = max_render_score_cumulative
      @max_render_size = max_render_size
      @parser = parser
      @strict_filters = strict_filters
      @suppress_blank_control_flow_blocks = suppress_blank_control_flow_blocks
      @undefined = undefined

      @tags = {} #: Hash[String, _Tag]
      @filters = {} #: Hash[String, [untyped, Integer?]]
      setup_tags_and_filters

      # Render context registers that persist when copying an instance of
      # `RenderContext`.
      @persistent_registers = Set[:extends_stack] #: Set[Symbol]
    end

    #: (String,
    #   ?globals: _Namespace?,
    #   ?name: String?,
    #   ?overlay: _Namespace?,
    #   ?up_to_date: Proc::_Callable?) -> Template
    def parse(source, globals: nil, name: nil, overlay: nil, up_to_date: nil)
      Template.new(
        self,
        source,
        @parser.parse(self, source, name || "", @lexer.tokenize(self, source)),
        globals: globals,
        name: name,
        overlay: overlay,
        up_to_date: up_to_date
      )
    end

    # Parse and render template `source` with variables from `data`.
    #: (String, ?data: _Namespace?) -> String
    def render(source, data: nil)
      parse(source).render(data)
    end

    #: (String, ?globals: _Namespace?, ?context: RenderContext?, **untyped) -> Template
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
      @tags["assign"] = AssignTag
      @tags["capture"] = CaptureTag
      @tags["case"] = CaseTag
      @tags["comment"] = CommentTag
      @tags["cycle"] = CycleTag
      @tags["decrement"] = DecrementTag
      @tags["doc"] = DocTag
      @tags["echo"] = EchoTag
      @tags["increment"] = IncrementTag
      @tags["for"] = ForTag
    end

    #: (untyped, untyped, RenderContext, t_token) -> bool
    def contains?(left, right, context, token)
      return left.contains?(right, context) if left.is_a?(Drop)

      if left && right && left.respond_to?(:include?)
        left.include?(left.is_a?(String) ? right.to_s : right)
      else
        false
      end
    end

    #: (untyped, untyped, RenderContext, t_token) -> bool
    def eq?(left, right, context, token)
      return left.eq?(right, context) if left.is_a?(Drop)
      return right.eq?(left, context) if right.is_a?(Drop)

      left == right
    end

    #: (untyped, untyped, RenderContext, t_token) -> bool
    def lt?(left, right, context, token)
      return left.lt?(right, context) if left.is_a?(Drop)

      # TODO: handle non-orderable
      left < right
    end

    #: (untyped) -> bool
    def nothing?(obj)
      obj.nil? || obj == :nothing || obj.is_a?(UndefinedDrop)
    end

    #: (untyped, RenderContext) -> bool
    def truthy?(obj, context)
      obj.is_a?(Drop) ? obj.to_primitive(:boolean, context) : !!obj
    end

    #: (untyped, RenderContext, t_token) -> String
    def serialize(obj, context, token)
      if @auto_escape && obj.is_a?(Drop)
        html_safe = obj.to_html_safe_s
        return html_safe if html_safe
      end

      s = obj.is_a?(Array) ? obj.each { |i| serialize(i, context, token) }.join : to_string(obj, context, token)
      @auto_escape ? Luoma.escape(s) : s
    end

    #: (untyped, RenderContext, t_token) -> Array[untyped]
    def to_a(obj, context, token)
      if obj.is_a?(Array)
        obj
      elsif obj.is_a?(String)
        [obj]
      elsif nothing?(obj)
        []
      elsif obj.respond_to?(:to_a)
        obj.to_a
      else
        []
      end
    end

    #: (untyped, RenderContext, t_token) -> Integer
    def to_i(obj, context, token)
      # TODO: handle invalid integer
      obj.is_a?(Integer) ? obj : Integer(obj)
    end

    #: (untyped, RenderContext, t_token) -> String
    def to_string(obj, context, token)
      case obj
      when Hash, Array
        JSON.generate(obj)
      when BigDecimal
        obj.to_s("F")
      when Drop
        obj.to_primitive(:string, context)
      when Symbol
        ""
      else
        obj.to_s
      end
    end

    #: (String, String?, String?) -> String
    def trim(value, left, right)
      case left || @auto_trim
      when "-"
        value.lstrip!
      when "~"
        value.sub!(/\A[\r\n]+/, "")
      end

      case right
      when "-"
        value.rstrip!
      when "~"
        value.sub!(/[\r\n]+\Z/, "")
      end

      value
    end

    protected

    #: (_Namespace?) -> _Namespace?
    def make_globals(namespace)
      namespaces = [namespace, @globals].compact
      ChainHash.new(*namespaces) unless namespaces.empty?
    end
  end
end
