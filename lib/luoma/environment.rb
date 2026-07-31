# frozen_string_literal: true

require "json"

module Luoma
  class Environment
    attr_reader :persistent_registers

    attr_accessor :auto_trim, :globals, :lexer, :loader, :parser, :strict,
                  :suppress_blank_control_flow_blocks, :undefined, :filters, :tags, :max_assign_score_cumulative,
                  :max_assign_score, :max_context_depth, :max_render_score_cumulative, :max_render_score,
                  :max_render_size, :predicates

    RE_INTEGER = /\A-?\d+(?:[eE]\+?\d+)?\Z/
    RE_DECIMAL = /((?:-?\d+\.\d+(?:[eE][+-]?\d+)?)|(-?\d+[eE]-\d+))/

    def initialize(
      auto_trim: nil,
      globals: nil,
      lexer: UnifiedLexer,
      loader: nil,
      max_assign_score_cumulative: nil,
      max_assign_score: nil,
      max_context_depth: 30,
      max_render_score_cumulative: nil,
      max_render_score: nil,
      max_render_size: nil,
      parser: UnifiedParser,
      strict: false,
      suppress_blank_control_flow_blocks: true,
      undefined: UndefinedDrop
    )
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
      @strict = strict
      @suppress_blank_control_flow_blocks = suppress_blank_control_flow_blocks
      @undefined = undefined

      @tags = {} #: Hash[String, _Tag]
      @filters = {} #: Hash[String, untyped]
      @predicates = {} #: Hash[String, ^(untyped) -> bool]
      setup_tags_filters_and_predicates

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
    #
    #: (String, ?t_namespace?) -> String
    def render(source, data = nil)
      parse(source).render(data)
    end

    #: (String, ?globals: _Namespace?, ?context: RenderContext?, **untyped) -> Template
    def get_template(name, globals: nil, context: nil, **)
      @loader.load(self, name, globals: globals, context: context, **)
    end

    # Add or replace a filter. The same callable can be registered multiple
    # times with different names.
    #
    # When evaluated as a filter, _callable_ will be called with an instance of
    # `FilterContext` as the first argument, and the result of the expression
    # to the left of the pipe operator as the second argument.
    #
    # Remaining positional and keyword arguments are passed through from the
    # filter invocation.
    #
    #: (String, untyped) -> void
    def register_filter(name, callable)
      @filters[name] = callable
    end

    # Remove a filter from the filter register.
    #
    #: (String) -> untyped
    def delete_filter(name)
      @filters.delete(name)
    end

    # Add or replace a tag.
    #
    #: (String, _Tag) -> void
    def register_tag(name, tag)
      @tags[name] = tag
    end

    # Remove a tag from the tag register.
    #
    #: (String) -> (_Tag | nil)
    def delete_tag(name)
      @tags.delete(name)
    end

    # Add or replace a predicate function.
    #
    #: (String, ^(untyped) -> bool) -> void
    def register_predicate(name, callable)
      @predicates[name] = callable
    end

    # Remove a predicate from the predicate register.
    #
    #: (String) -> (^(untyped) -> bool | nil)
    def delete_predicate(name)
      @predicates.delete(name)
    end

    #: () -> void
    def setup_tags_filters_and_predicates
      @tags["assign"] = AssignTag
      @tags["capture"] = CaptureTag
      @tags["case"] = CaseTag
      @tags["define"] = DefineTag
      @tags["for"] = ForTag
      @tags["break"] = BreakTag
      @tags["continue"] = ContinueTag
      @tags["if"] = IfTag
      @tags["import"] = ImportTag
      @tags["include"] = IncludeTag
      @tags["raw"] = RawTag
      @tags["render"] = RenderTag
      @tags["with"] = WithTag

      register_filter("abs", Luoma::Filters.method(:abs))
      register_filter("all", Luoma::Filters.method(:all))
      register_filter("any", Luoma::Filters.method(:any))
      register_filter("append", Luoma::Filters.method(:append))
      register_filter("at_least", Luoma::Filters.method(:at_least))
      register_filter("at_most", Luoma::Filters.method(:at_most))
      register_filter("capitalize", Luoma::Filters.method(:capitalize))
      register_filter("ceil", Luoma::Filters.method(:ceil))
      register_filter("compact", Luoma::Filters.method(:compact))
      register_filter("concat", Luoma::Filters.method(:concat))
      register_filter("date", Luoma::Filters.method(:date))
      register_filter("default", Luoma::Filters.method(:default))
      register_filter("divided_by", Luoma::Filters.method(:divided_by))
      register_filter("downcase", Luoma::Filters.method(:downcase))
      register_filter("escape_js", Luoma::Filters.method(:escape_js))
      register_filter("escape_once", Luoma::Filters.method(:escape_once))
      register_filter("escape", Luoma::Filters.method(:escape))
      register_filter("find_index", Luoma::Filters.method(:find_index))
      register_filter("find", Luoma::Filters.method(:find))
      register_filter("first", Luoma::Filters.method(:first))
      register_filter("flatten", Luoma::Filters.method(:flatten))
      register_filter("flat_map", Luoma::Filters.method(:flat_map))
      register_filter("floor", Luoma::Filters.method(:floor))
      register_filter("join", Luoma::Filters.method(:join))
      register_filter("json", Luoma::Filters.method(:json))
      register_filter("last", Luoma::Filters.method(:last))
      register_filter("lstrip", Luoma::Filters.method(:lstrip))
      register_filter("map", Luoma::Filters.method(:map))
      register_filter("max", Luoma::Filters.method(:max))
      register_filter("min", Luoma::Filters.method(:min))
      register_filter("minus", Luoma::Filters.method(:minus))
      register_filter("modulo", Luoma::Filters.method(:modulo))
      register_filter("newline_to_br", Luoma::Filters.method(:newline_to_br))
      register_filter("plus", Luoma::Filters.method(:plus))
      register_filter("prepend", Luoma::Filters.method(:prepend_))
      register_filter("squish", Luoma::Filters.method(:squish))
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
      register_filter("sort_numeric", Luoma::Filters.method(:sort_numeric))
      register_filter("split", Luoma::Filters.method(:split))
      register_filter("strip_html", Luoma::Filters.method(:strip_html))
      register_filter("strip_newlines", Luoma::Filters.method(:strip_newlines))
      register_filter("strip", Luoma::Filters.method(:strip))
      register_filter("sum", Luoma::Filters.method(:sum))
      register_filter("take", Luoma::Filters.method(:take))
      register_filter("times", Luoma::Filters.method(:times))
      register_filter("truncate", Luoma::Filters.method(:truncate))
      register_filter("truncatewords", Luoma::Filters.method(:truncatewords))
      register_filter("uniq", Luoma::Filters.method(:uniq))
      register_filter("upcase", Luoma::Filters.method(:upcase))
      register_filter("url_decode", Luoma::Filters.method(:url_decode))
      register_filter("url_encode", Luoma::Filters.method(:url_encode))
      register_filter("where", Luoma::Filters.method(:where))
      register_filter("filter", Luoma::Filters.method(:where))
      register_filter("zip", Luoma::Filters.method(:zip))

      register_predicate("array", Luoma::Predicates.method(:array?))
      register_predicate("blank", Luoma::Predicates.method(:blank?))
      register_predicate("defined", Luoma::Predicates.method(:defined?))
      register_predicate("empty", Luoma::Predicates.method(:empty?))
      register_predicate("null", Luoma::Predicates.method(:null?))
      register_predicate("number", Luoma::Predicates.method(:number?))
      register_predicate("numeric", Luoma::Predicates.method(:numeric?))
      register_predicate("object", Luoma::Predicates.method(:object?))
      register_predicate("string", Luoma::Predicates.method(:string?))
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
      # TODO: Don't accepts token
      return left.eq?(right, context) if left.is_a?(Drop)
      return right.eq?(left, context) if right.is_a?(Drop)

      left == right
    end

    #: (untyped, untyped, RenderContext, t_token) -> bool?
    def lt?(left, right, context, token)
      # TODO: Don't accepts token
      return left.lt?(right, context) if left.is_a?(Drop)
      return right.gt?(left, context) if right.is_a?(Drop)

      left < right
    rescue ArgumentError, NoMethodError, TypeError
      nil
    end

    #: (untyped, untyped, RenderContext, t_token) -> (-1 | 1 | 0 | nil)
    def cmp(left, right, context, token)
      return -1 if lt?(left, right, context, token)
      return  1 if lt?(right, left, context, token)
      return  0 if eq?(left, right, context, token)

      if left.nil? || nothing?(left)
        1
      elsif right.nil? || nothing?(right)
        -1
      end
    end

    #: (untyped) -> bool
    def nothing?(obj)
      obj == :nothing || obj.is_a?(UndefinedDrop)
    end

    #: (untyped, RenderContext) -> bool
    def truthy?(obj, context)
      obj = obj.to_primitive(:boolean, context) if obj.is_a?(Drop)
      !nothing?(obj) && !!obj
    end

    #: (untyped, RenderContext) -> String
    def serialize(obj, context)
      case obj
      when Drop
        s = obj.render(context)
        s.nil? ? to_string(obj, context) : s
      when Array
        if obj.all?(String)
          to_string(obj, context)
        elsif obj.all?(BlockDrop)
          obj.map { |i| i.render(context) }.join("\n")
        elsif obj.all? { |i| i.is_a?(String) || i.is_a?(BlockDrop) }
          obj.map { |i| i.is_a?(String) ? i : i.render(context) }.join
        else # rubocop: disable Lint/DuplicateBranch
          to_string(obj, context)
        end
      else
        to_string(obj, context)
      end
    end

    #: (untyped, RenderContext) -> Array[untyped]
    def to_a(obj, context)
      if obj.is_a?(Array)
        obj
      elsif obj.is_a?(String)
        obj.each_char.to_a
      elsif obj.respond_to?(:to_a)
        obj.to_a
      else
        [obj]
      end
    end

    #: (untyped, RenderContext) -> Hash[untyped, untyped]
    def to_h(obj, context)
      if obj.is_a?(Hash)
        obj
      elsif obj.is_a(Drop)
        obj = obj.to_primitive("object", context)
        nothing?(obj) ? {} : obj
      elsif obj.respond_to?(:to_h)
        obj.to_h
      else
        {}
      end
    end

    # Try to coerce `obj` to an integer using `#to_i` with a fallback to
    # `Integer(obj.to_s)` if `obj` does not respond to `to_i`.
    #
    #: [X] (untyped, RenderContext, ?default: X) -> (Integer | X)
    def to_i(obj, context, default: :nothing)
      return obj if obj.is_a?(Integer)
      return obj.to_i if obj.respond_to?(:to_i) && !obj.is_a?(String)

      begin
        Integer(obj.to_s)
      rescue ::ArgumentError
        default
      end
    end

    #: [X] (untyped, ?default: X) -> (Numeric | X)
    def to_numeric(obj, context, default: :nothing)
      case obj
      when ::Float
        BigDecimal(obj)
      when Numeric
        obj
      when ::String
        case obj
        when RE_INTEGER
          obj.to_f.to_i
        when RE_DECIMAL
          BigDecimal(obj)
        else
          default
        end
      when true
        1
      when false
        0
      when Drop
        n = obj.to_primitive(:numeric, context)
        n == :nothing ? default : n
      else
        default
      end
    end

    #: (untyped) -> Enumerable
    def to_enumerable(obj, context)
      case obj
      when Drop
        obj.each
      when Enumerable
        obj.to_enum
      when String
        obj.each_char
      else
        obj.respond_to?(:each) ? obj.each : [obj]
      end
    end

    #: (untyped, RenderContext) -> String
    def to_string(obj, context)
      case obj
      when String
        obj
      when Hash, Array
        JSON.generate(to_data(obj, context))
      when BigDecimal
        # obj.to_s("F") gives higher precision
        obj.to_f.to_s
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
    def to_date(obj, context)
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

    #: (untyped, RenderContext) -> untyped
    def to_data(obj, context)
      case obj
      when nil, true, false, Numeric, String
        obj
      when Array
        obj.map { |v| to_data(v, context) }
      when Hash
        obj.transform_values { |v| to_data(v, context) }
      when Drop
        obj.to_primitive(:data, context)
      when Symbol
        ""
      end
    end
  end
end
