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
      @filters = {} #: Hash[String, t_filter]
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
        globals: make_globals(globals),
        name: name,
        overlay: overlay,
        up_to_date: up_to_date
      )
    end

    # Parse and render template `source` with variables from `data`.
    #: (String, ?t_namespace?) -> String
    def render(source, data = nil)
      parse(source).render(data)
    end

    #: (String, ?globals: _Namespace?, ?context: RenderContext?, **untyped) -> Template
    def get_template(name, globals: nil, context: nil, **)
      @loader.load(self, name, globals: globals, context: context, **)
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
    #: (String, untyped) -> void
    def register_filter(name, callable)
      @filters[name] = callable
    end

    # Remove a filter from the filter register.
    # @param name [String] The name of the filter.
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
      @tags["for"] = ForTag
      @tags["break"] = BreakTag
      @tags["continue"] = ContinueTag
      @tags["if"] = IfTag
      @tags["ifchanged"] = IfChangedTag
      @tags["increment"] = IncrementTag
      @tags["unless"] = UnlessTag

      register_filter("abs", Luoma::Filters.method(:abs))
      register_filter("append", Luoma::Filters.method(:append))
      register_filter("at_least", Luoma::Filters.method(:at_least))
      register_filter("at_most", Luoma::Filters.method(:at_most))
      register_filter("base64_decode", Luoma::Filters.method(:base64_decode))
      register_filter("base64_encode", Luoma::Filters.method(:base64_encode))
      register_filter("base64_url_safe_decode", Luoma::Filters.method(:base64_url_safe_decode))
      register_filter("base64_url_safe_encode", Luoma::Filters.method(:base64_url_safe_encode))
      register_filter("capitalize", Luoma::Filters.method(:capitalize))
      register_filter("ceil", Luoma::Filters.method(:ceil))
      register_filter("compact", Luoma::Filters.method(:compact))
      register_filter("concat", Luoma::Filters.method(:concat))
      register_filter("date", Luoma::Filters.method(:date))
      register_filter("default", Luoma::Filters.method(:default))
      register_filter("divided_by", Luoma::Filters.method(:divided_by))
      register_filter("downcase", Luoma::Filters.method(:downcase))
      register_filter("escape_once", Luoma::Filters.method(:escape_once))
      register_filter("escape", Luoma::Filters.method(:escape))
      register_filter("find_index", Luoma::Filters.method(:find_index))
      register_filter("find", Luoma::Filters.method(:find))
      register_filter("first", Luoma::Filters.method(:first))
      register_filter("floor", Luoma::Filters.method(:floor))
      register_filter("has", Luoma::Filters.method(:has))
      register_filter("join", Luoma::Filters.method(:join))
      register_filter("last", Luoma::Filters.method(:last))
      register_filter("lstrip", Luoma::Filters.method(:lstrip))
      register_filter("map", Luoma::Filters.method(:map))
      register_filter("minus", Luoma::Filters.method(:minus))
      register_filter("modulo", Luoma::Filters.method(:modulo))
      register_filter("newline_to_br", Luoma::Filters.method(:newline_to_br))
      register_filter("plus", Luoma::Filters.method(:plus))
      register_filter("prepend", Luoma::Filters.method(:prepend_))
      register_filter("reject", Luoma::Filters.method(:reject))
      register_filter("remove_first", Luoma::Filters.method(:remove_first))
      register_filter("remove_last", Luoma::Filters.method(:remove_last))
      register_filter("remove", Luoma::Filters.method(:remove))
      register_filter("replace_first", Luoma::Filters.method(:replace_first))
      register_filter("replace_last", Luoma::Filters.method(:replace_last))
      register_filter("replace", Luoma::Filters.method(:replace))
      register_filter("reverse", Luoma::Filters.method(:reverse))
      register_filter("round", Luoma::Filters.method(:round))
      register_filter("rstrip", Luoma::Filters.method(:rstrip))
      register_filter("size", Luoma::Filters.method(:size))
      register_filter("slice", Luoma::Filters.method(:slice))
      register_filter("sort", Luoma::Filters.method(:sort))
      register_filter("sort_natural", Luoma::Filters.method(:sort_natural))
      register_filter("split", Luoma::Filters.method(:split))
      register_filter("strip_html", Luoma::Filters.method(:strip_html))
      register_filter("strip_newlines", Luoma::Filters.method(:strip_newlines))
      register_filter("strip", Luoma::Filters.method(:strip))
      register_filter("sum", Luoma::Filters.method(:sum))
      register_filter("times", Luoma::Filters.method(:times))
      register_filter("truncate", Luoma::Filters.method(:truncate))
      register_filter("truncatewords", Luoma::Filters.method(:truncatewords))
      register_filter("uniq", Luoma::Filters.method(:uniq))
      register_filter("upcase", Luoma::Filters.method(:upcase))
      register_filter("url_decode", Luoma::Filters.method(:url_decode))
      register_filter("url_encode", Luoma::Filters.method(:url_encode))
    end

    #: (untyped, untyped, RenderContext, t_token) -> bool
    def contains?(left, right, context, token)
      return left.contains?(right, context) if left.is_a?(Drop)

      right = right.to_primitive(:data, context) if right.is_a?(Drop)

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

      left < right
    rescue ArgumentError => e
      raise TemplateTypeError.new(
        e.message,
        token,
        context.template.source,
        context.template.name
      )
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
      elsif obj.respond_to?(:to_a)
        obj.to_a
      else
        []
      end
    end

    #: (untyped, RenderContext, t_token, ?default: Integer?) -> Integer
    def to_i(obj, context, token, default: nil)
      return obj if obj.is_a?(Integer)
      return obj.to_i if obj.respond_to?(:to_i) && !obj.is_a?(String)

      begin
        Integer(obj.to_s)
      rescue ::ArgumentError
        return default if default

        raise TemplateTypeError.new(
          "invalid integer",
          token,
          context.template.source,
          context.template.name
        )
      end
    end

    #: (untyped, ?default: Numeric?) -> Numeric
    def to_numeric(obj, default: 0)
      case obj
      when Float, Integer, BigDecimal, Numeric
        # Numeric is the base class for heap allocated numbers.
        obj
      when String
        # Cast to float before integer as `to_f` will parse exponents, `to_i` will not.
        # Use `Float(obj)` instead of `obj.to_f` because `to_f` ignores trailing non-digit chars.
        obj.match?(/\A-?\d+(?:[eE]\+?\d+)?\Z/) ? obj.to_f.to_i : Float(obj)
      else
        default
      end
    rescue ArgumentError
      default
    end

    # Cast `obj` to a number, favouring BigDecimal over Float.
    # Returns `default` if `obj` can't be cast to a numeric value.
    #: (untyped, ?default: Numeric?) -> Numeric
    def to_decimal(obj, default: 0)
      case obj
      when String
        obj.match?(/\A-?\d+(?:[eE]\+?\d+)?\Z/) ? obj.to_f.to_i : BigDecimal(obj)
      when Float
        BigDecimal(obj.to_s)
      when Integer, BigDecimal, Numeric
        obj
      else
        default
      end
    rescue ArgumentError
      default
    end

    #: (untyped) -> Enumerable
    def to_enumerable(obj)
      case obj
      when Array
        obj.flatten
      when Hash, String
        [obj]
      when Drop
        obj.each
      when Enumerable
        obj
      else
        obj.respond_to?(:each) ? obj.each : [obj]
      end
    end

    #: (untyped, RenderContext, t_token) -> String
    def to_string(obj, context, token)
      case obj
      when String
        obj
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

    # Cast _obj_ to a  date and time. Return `nil` if casting fails.
    # NOTE: This was copied from Shopify/liquid.
    def to_date(obj)
      return obj if obj.respond_to?(:strftime)

      if obj.is_a?(String)
        return nil if obj.empty?

        obj = obj.downcase
      end

      case obj
      when "now", "today"
        Time.now
      when /\A\d+\z/, Integer
        Time.at(obj.to_i)
      when String
        Time.parse(obj)
      end
    rescue ::ArgumentError
      nil
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

    #: (t_namespace?) -> t_namespace?
    def make_globals(namespace)
      namespace_ = {} #: t_namespace
      namespace_.merge!(@globals) if @globals # steep:ignore
      namespace_.merge!(namespace) if namespace
      namespace_
    end
  end
end
