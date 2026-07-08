# frozen_string_literal: true

# rubocop:disable Naming/PredicateMethod

module Luoma
  # The base class for all expressions.
  class Expression
    attr_reader :token, :span

    #: (t_token) -> void
    def initialize(token)
      @token = token
      @span = token
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      raise "not implemented"
    end

    def children
      raise "not implemented"
    end

    #: () -> String
    def to_s
      raise "not implemented"
    end
  end

  class GroupExpression < Expression
    #: (t_token, Expression, Array[t_path_segment]) -> void
    def initialize(token, expr, segments)
      super(token)
      @expr = expr
      @segments = segments

      @span = if segments.empty?
                Luoma.span(token, expr.span)
              else
                Luoma.span(token, segments.last.token)
              end
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      obj = @expr.evaluate(context)
      obj = context.resolve_path(obj, @segments.map { |s| s.evaluate(context) }) unless @segments.empty?
      obj
    end

    def children
      [@expr, *@segments.grep(Variable)] #: Array[_Traversable]
    end

    def with(token)
      @span = Luoma.span(@token, token)
      self
    end

    #: () -> String
    def to_s
      "(#{@expr})#{path(@segments)}"
    end

    private

    #: (Array[t_path_segment]) -> String
    def path(segments)
      if segments.empty?
        ""
      else
        segments.map { |s| s.is_a?(Name) ? ".#{s}" : "[#{s}]" }.join
      end
    end
  end

  class TernaryExpression < Expression
    #: (t_token, Expression, Expression, Expression?) -> void
    def initialize(token, consequence, condition, alternative)
      super(token)
      @consequence = consequence
      @condition = condition
      @alternative = alternative
      @span = Luoma.span(@consequence.token, (@alternative || @condition).span)
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      if context.env.truthy?(@condition.evaluate(context), context)
        @consequence.evaluate(context)
      else
        @alternative&.evaluate(context) || :nothing
      end
    end

    def children
      [@consequence, @condition, @alternative].compact
    end

    #: () -> String
    def to_s
      if @alternative
        "#{@consequence} if #{@condition} else #{@alternative}"
      else
        "#{@consequence} if #{@condition}"
      end
    end
  end

  class FilteredExpression < Expression
    #: (t_token, Expression, Filter) -> void
    def initialize(token, left, filter)
      super(token)
      @left = left
      @filter = filter
      @span = filter.span
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      func = context.env.filters[@filter.name.value]

      if func.nil?
        if context.env.strict_filters
          raise FilterNotFoundError.new(
            "unknown filter #{@filter.name.value.inspect}",
            @filter.token,
            context.template.source,
            context.template.name
          )
        end

        return :nothing
      end

      filter_context = FilterContext.new(@token, context)
      left = @left.evaluate(context)

      return func.call(filter_context, left) if @filter.args.empty? && @filter.kwargs.empty?

      if @filter.kwargs.empty?
        func.call(filter_context, left, *@filter.args.map { |arg| arg.evaluate(context) }) # steep:ignore
      else
        func.call(
          filter_context,
          left,
          *@filter.args.map { |arg| arg.evaluate(context) }, # steep:ignore
          **@filter.kwargs.to_h { |arg| [arg.name.value.to_sym, arg.expression.evaluate(context)] } # steep:ignore
        )
      end
    rescue TypeError, ArgumentError => e
      raise FilterArgumentError.new(
        e.message,
        @span,
        context.template.source,
        context.template.name
      )
    end

    def children
      [@left, @filter]
    end

    #: () -> String
    def to_s
      "#{@left} | #{@filter}"
    end
  end

  class PrefixExpression < Expression
    #: (t_token, Expression) -> void
    def initialize(token, right)
      super(token)
      @right = right
      @span = Luoma.span(token, right.span)
    end

    def children
      [@right]
    end
  end

  class NotExpression < PrefixExpression
    def evaluate(context)
      !context.env.truthy?(@right.evaluate(context), context)
    end

    #: () -> String
    def to_s
      "not #{@right}"
    end
  end

  class PosExpression < PrefixExpression
    def evaluate(context)
      context.env.to_numeric(@right.evaluate(context), context, default: :nothing)
    end

    #: () -> String
    def to_s
      "+#{@right}"
    end
  end

  class NegExpression < PrefixExpression
    def evaluate(context)
      right = context.env.to_numeric(@right.evaluate(context), context, default: :nothing)
      context.env.nothing?(right) ? :nothing : -right # steep:ignore
    end

    #: () -> String
    def to_s
      "+#{@right}"
    end
  end

  class InfixExpression < Expression
    #: (t_token, Expression, Expression) -> void
    def initialize(token, left, right)
      super(token)
      @left = left
      @right = right
      @span = Luoma.span(left.span, right.span)
    end

    def children
      [@left, @right]
    end
  end

  class CoalesceExpression < InfixExpression
    #: (RenderContext) -> untyped
    def evaluate(context)
      left = @left.evaluate(context)
      context.env.nothing?(left) ? @right.evaluate(context) : left
    end

    #: () -> String
    def to_s
      "#{@left} orElse #{@right}"
    end
  end

  class OrExpression < InfixExpression
    #: (RenderContext) -> untyped
    def evaluate(context)
      left = @left.evaluate(context)
      context.env.truthy?(left, context) ? left : @right.evaluate(context)
    end

    #: () -> String
    def to_s
      "#{@left} or #{@right}"
    end
  end

  class AndExpression < InfixExpression
    #: (RenderContext) -> untyped
    def evaluate(context)
      left = @left.evaluate(context)
      context.env.truthy?(left, context) ? @right.evaluate(context) : left
    end

    #: () -> String
    def to_s
      "#{@left} and #{@right}"
    end
  end

  class EqExpression < InfixExpression
    #: (RenderContext) -> untyped
    def evaluate(context)
      context.env.eq?(@left.evaluate(context), @right.evaluate(context), context, @span)
    end

    #: () -> String
    def to_s
      "#{@left} == #{@right}"
    end
  end

  class NeExpression < InfixExpression
    #: (RenderContext) -> untyped
    def evaluate(context)
      !context.env.eq?(@left.evaluate(context), @right.evaluate(context), context, @span)
    end

    #: () -> String
    def to_s
      "#{@left} != #{@right}"
    end
  end

  class LtExpression < InfixExpression
    #: (RenderContext) -> untyped
    def evaluate(context)
      context.env.lt?(@left.evaluate(context), @right.evaluate(context), context, @span)
    end

    #: () -> String
    def to_s
      "#{@left} < #{@right}"
    end
  end

  class LeExpression < InfixExpression
    #: (RenderContext) -> untyped
    def evaluate(context)
      left = @left.evaluate(context)
      right = @right.evaluate(context)
      context.env.lt?(left, right, context, @span) || context.env.eq?(left, right, context, @span)
    end

    #: () -> String
    def to_s
      "#{@left} <= #{@right}"
    end
  end

  class GtExpression < InfixExpression
    #: (RenderContext) -> untyped
    def evaluate(context)
      context.env.lt?(@right.evaluate(context), @left.evaluate(context), context, @span)
    end

    #: () -> String
    def to_s
      "#{@left} > #{@right}"
    end
  end

  class GeExpression < InfixExpression
    #: (RenderContext) -> untyped
    def evaluate(context)
      left = @left.evaluate(context)
      right = @right.evaluate(context)
      context.env.lt?(right, left, context, @span) || context.env.eq?(left, right, context, @span)
    end

    #: () -> String
    def to_s
      "#{@left} >= #{@right}"
    end
  end

  class ContainsExpression < InfixExpression
    #: (RenderContext) -> untyped
    def evaluate(context)
      context.env.contains?(@left.evaluate(context), @right.evaluate(context), context, @span)
    end

    #: () -> String
    def to_s
      "#{@left} contains #{@right}"
    end
  end

  class InExpression < InfixExpression
    #: (RenderContext) -> untyped
    def evaluate(context)
      context.env.contains?(@right.evaluate(context), @left.evaluate(context), context, @span)
    end

    #: () -> String
    def to_s
      "#{@left} in #{@right}"
    end
  end

  class AddExpression < InfixExpression
    #: (RenderContext) -> untyped
    def evaluate(context)
      left = context.env.to_numeric(@left.evaluate(context), context, default: :nothing)
      right = context.env.to_numeric(@right.evaluate(context), context, default: :nothing)
      left == :nothing || right == :nothing ? :nothing : left + right # steep:ignore
    end

    #: () -> String
    def to_s
      "#{@left} + #{@right}"
    end
  end

  class SubExpression < InfixExpression
    #: (RenderContext) -> untyped
    def evaluate(context)
      left = context.env.to_numeric(@left.evaluate(context), context, default: :nothing)
      right = context.env.to_numeric(@right.evaluate(context), context, default: :nothing)
      left == :nothing || right == :nothing ? :nothing : left - right # steep:ignore
    end

    #: () -> String
    def to_s
      "#{@left} - #{@right}"
    end
  end

  class MulExpression < InfixExpression
    #: (RenderContext) -> untyped
    def evaluate(context)
      left = context.env.to_numeric(@left.evaluate(context), context, default: :nothing)
      right = context.env.to_numeric(@right.evaluate(context), context, default: :nothing)
      left == :nothing || right == :nothing ? :nothing : left * right # steep:ignore
    end

    #: () -> String
    def to_s
      "#{@left} * #{@right}"
    end
  end

  class DivExpression < InfixExpression
    #: (RenderContext) -> untyped
    def evaluate(context)
      lhs = context.env.to_numeric(@left.evaluate(context), context, default: :nothing)
      rhs = context.env.to_numeric(@right.evaluate(context), context, default: :nothing)
      return :nothing if lhs == :nothing || rhs == :nothing || rhs.zero? # steep:ignore

      result = lhs.to_d / rhs # steep:ignore
      result.frac.zero? && lhs.is_a?(::Integer) && rhs.is_a?(::Integer) ? result.to_i : result
    end

    #: () -> String
    def to_s
      "#{@left} / #{@right}"
    end
  end

  class ModExpression < InfixExpression
    #: (RenderContext) -> untyped
    def evaluate(context)
      lhs = context.env.to_numeric(@left.evaluate(context), context, default: :nothing)
      rhs = context.env.to_numeric(@right.evaluate(context), context, default: :nothing)
      return :nothing if lhs == :nothing || rhs == :nothing || rhs.zero? # steep:ignore

      result = lhs.to_d % rhs # steep:ignore
      result.frac.zero? && lhs.is_a?(::Integer) && rhs.is_a?(::Integer) ? result.to_i : result
    end

    #: () -> String
    def to_s
      "#{@left} % #{@right}"
    end
  end

  class Variable < Expression
    attr_reader :root, :segments

    #: (t_token, Name | StringLiteral | Variable, Array[t_path_segment]) -> void
    def initialize(token, root, segments)
      super(token)
      @root = root
      @segments = segments
      @span = segments.empty? ? root.span : Luoma.span(root.span, segments.last.span)
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      root_segment = @root.is_a?(Variable) ? @root.evaluate(context) : @root.value # steep:ignore
      root = root_segment.is_a?(String) ? context.scopes.fetch(root_segment, :nothing) : :nothing

      obj, index = if @segments.empty?
                     [root, 0]
                   else
                     context.resolve_path(root, @segments.map { |s| s.evaluate(context) })
                   end

      if obj == :nothing
        context.env.undefined.new(
          path(@segments[0..index] || raise),
          @span,
          context.template.source,
          context.template.name
        )
      else
        obj
      end
    end

    def children
      if @root.is_a?(Variable)
        [@root, *@segments.grep(Variable)] #: Array[_Traversable]
      else
        @segments.filter.grep(Variable) #: Array[_Traversable]
      end
    end

    #: () -> String
    def to_s
      path(@segments)
    end

    # Return true if this variable has a root segment matching `name` and
    # no other segments.
    #: (String) -> bool
    def ident?(name)
      @segments.empty? && @root.is_a?(Name) && @root.value == name # steep:ignore
    end

    private

    #: (Array[t_path_segment]) -> String
    def path(segments)
      root = @root.is_a?(Name) ? @root.to_s : "[#{@root}]"
      return root if segments.empty?

      segments_ = segments.map { |s| s.is_a?(Name) ? ".#{s}" : "[#{s}]" }.join
      "#{root}#{segments_}"
    end
  end

  class IndexSelector < Expression
    attr_reader :value

    #: (t_token, Integer)
    def initialize(token, value)
      super(token)
      @value = value
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      @value
    end

    def children
      []
    end

    #: () -> String
    def to_s
      @value.to_s
    end

    def with(token)
      @span = Luoma.span(@token, token)
      self
    end
  end

  class Lambda < Expression
    #: (t_token, Array[Name], Expression) -> void
    def initialize(token, params, expr)
      super(token)
      @params = params
      @expr = expr
      @span = Luoma.span(token, expr.span)
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      LambdaExpr.new(@params.map(&:value), @expr, context)
    end

    def children
      [@expr]
    end

    #: () -> String
    def to_s
      "(#{@params.join(", ")}) => #{@expr}"
    end
  end

  class StringLiteral < Expression
    attr_reader :segments

    #: (t_token, Array[String|Expression], t_token)
    def initialize(token, segments, end_token)
      super(token)
      @segments = segments
      @span = Luoma.span(token, end_token)
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      result = @segments.map do |s|
        s.is_a?(String) ? s : context.env.to_string(s.evaluate(context), context)
      end.join

      context.env.auto_escape ? HTMLSafeDrop.from(result) : result
    end

    def children
      @segments.grep_v(String) #: Array[Expression]
    end

    #: () -> String
    def to_s
      @segments.map { |s| s.is_a?(String) ? s : "${#{s}}" }.join.inspect
    end

    def with(token)
      @span = Luoma.span(@token, token)
      self
    end

    # Return the string, or nil if the string literal contains interpolated expressions.
    #: () -> String?
    def value
      @segments.first if @segments.length == 1 && @segments.first.is_a?(String) #: String?
    end
  end

  class IntegerLiteral < Expression
    attr_reader :value

    #: (t_token, Integer)
    def initialize(token, value)
      super(token)
      @value = value
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      @value
    end

    def children
      []
    end

    #: () -> String
    def to_s
      @value.to_s
    end
  end

  class FloatLiteral < Expression
    attr_reader :value

    #: (t_token, Float)
    def initialize(token, value)
      super(token)
      @value = value
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      @value
    end

    def children
      []
    end

    #: () -> String
    def to_s
      @value.to_s
    end
  end

  class BooleanLiteral < Expression
    attr_reader :value

    #: (t_token, bool)
    def initialize(token, value)
      super(token)
      @value = value
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      @value
    end

    def children
      []
    end

    #: () -> String
    def to_s
      @value.to_s
    end
  end

  class NullLiteral < Expression
    #: (RenderContext) -> untyped
    def evaluate(context)
      nil
    end

    def children
      []
    end

    #: () -> String
    def to_s
      ""
    end
  end

  class RangeLiteral < Expression
    #: (t_token, Expression, Expression) -> void
    def initialize(token, start, stop)
      super(token)
      @start = start
      @stop = stop
      @span = Luoma.span(start.token, stop.token)
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      start = context.env.to_i(@start.evaluate(context), context, default: 0)
      stop = context.env.to_i(@stop.evaluate(context), context, default: 0)
      RangeDrop.new(start, stop)
    end

    def children
      [@start, @stop]
    end

    #: () -> String
    def to_s
      "(#{@start}..#{@stop})"
    end
  end

  class ArrayLiteral < Expression
    #:  (t_token token, Array[Expression|Spread] items) -> void
    def initialize(token, items)
      super(token)
      @items = items
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      result = [] #: Array[untyped]

      @items.each do |item|
        if item.is_a?(Spread)
          result.concat(context.env.to_a(item.expr.evaluate(context), context))
        else
          result << item.evaluate(context)
        end
      end

      result
    end

    def children
      @items
    end

    #: () -> String
    def to_s
      "[#{@items.join(", ")}]"
    end

    def with(token)
      @span = Luoma.span(@token, token)
      self
    end
  end

  class ObjectLiteral < Expression
    #:  (t_token token, Array[Item|Spread] items) -> void
    def initialize(token, items)
      super(token)
      @items = items
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      result = {} #: Hash[String, untyped]

      @items.each do |item|
        if item.is_a?(Spread)
          result.update(context.env.to_h(item.expr.evaluate(context), context))
        else
          result[item.key.value] = item.expr.evaluate(context)
        end
      end

      result
    end

    def children
      @items
    end

    #: () -> String
    def to_s
      "{#{@items.join(", ")}}"
    end

    def with(token)
      @span = Luoma.span(@token, token)
      self
    end
  end

  class Predicate < Expression
    #:  (t_token, String) -> void
    def initialize(token, value)
      super(token)
      @value = value
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      func = context.env.predicates[@value]

      if func.nil?
        :nothing
      else
        PredicateFunction.new(@value, func)
      end
    end

    def children
      []
    end

    #: () -> String
    def to_s
      @value
    end
  end

  class Spread
    attr_reader :token, :expr

    #: (t_token, Expression) -> void
    def initialize(token, expr)
      @token = token
      @expr = expr
    end

    def children
      [@expr]
    end

    #: () -> String
    def to_s
      "...#{@expr}"
    end
  end

  class Item
    attr_reader :token, :key, :expr

    #: (t_token, Name, Expression) -> void
    def initialize(token, key, expr)
      @token = token
      @key = key
      @expr = expr
    end

    def children
      [@expr]
    end

    #: () -> String
    def to_s
      "#{@key}: #{@expr}"
    end
  end

  class Name
    attr_reader :token, :span, :value

    #: (t_token, String) -> void
    def initialize(token, value)
      @token = token
      @value = value
      @span = token
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      @value
    end

    def children
      []
    end

    #: () -> String
    def to_s
      @value
    end
  end

  class Filter
    attr_reader :token, :span, :name, :args, :kwargs

    #: (t_token, Name, Array[Expression], Array[KeywordArgument])
    def initialize(token, name, args, kwargs)
      @token = token
      @name = name
      @args = args
      @kwargs = kwargs
      @span = args.empty? ? token : Luoma.span(token, args.last.span)
    end

    def children
      @args
    end

    def to_s
      return @name.value if @args.empty? && @kwargs.empty?

      args = @args.join(",")
      args << ", " << @kwargs.join(",") unless @kwargs.empty?
      "#{@name}: #{args}"
    end
  end

  class KeywordArgument
    attr_reader :token, :span, :name, :expression

    #: (t_token, Name, Expression) -> void
    def initialize(token, name, expression)
      @token = token
      @name = name
      @expression = expression
      @span = Luoma.span(token, expression.span)
    end

    def children
      [@expression]
    end

    #: () -> String
    def to_s
      "#{@name}: #{@expression}"
    end

    def deconstruct
      [@name.value, @expression]
    end

    def deconstruct_keys(keys)
      { name: @name.value, expression: @expression }
    end
  end

  class PredicateFunction
    attr_reader :name, :func

    #: (String, ^(untyped) -> bool) -> void
    def initialize(name, func)
      @name = name
      @func = func
    end

    #: (untyped) -> bool
    def call(obj)
      @func.call(obj)
    end
  end

  class LambdaExpr
    #: (Array[String], Expression, RenderContext) -> void
    def initialize(params, expr, context)
      @params = params
      @expr = expr
      @context = context
    end

    #: (Enumerable[untyped]) -> Array[untyped]
    def broadcast(enum)
      scope = {} #: Hash[String, untyped]
      result = [] #: Array[untyped]

      if @params.length == 1
        param = @params[0]

        @context.extends(scope) do
          enum.each do |item|
            scope[param] = item
            result << @expr.evaluate(@context)
          end
        end
      else
        name_param = @params[0]
        index_param = @params[1]

        @context.extends(scope) do
          enum.each_with_index do |item, i|
            scope[index_param] = i
            scope[name_param] = item
            result << @expr.evaluate(@context)
          end
        end
      end

      result
    end

    #: (untyped, Integer) -> untyped
    def call(value, index)
      scope = { @params[0] => value }
      scope[@params[1]] = index if @params.length > 1

      @context.extends(scope) do
        @expr.evaluate(@context)
      end
    end
  end

  #: (Expression) -> String
  def self.tree_view(e)
    # (prefix, connector, class_name, inspect_value)
    nodes = [] # : Array[[String, String, String, String]]

    # @type var visit: ^(_Traversable, String, bool) -> void
    visit = lambda do |node, prefix, is_last|
      connector = if prefix.empty?
                    ""
                  elsif is_last
                    "└── "
                  else
                    "├── "
                  end

      nodes << [prefix, connector, node.class.to_s, node.to_s]
      child_prefix = prefix + (is_last ? "    " : "│   ")
      node.children.each_with_index do |child, i|
        last = i == node.children.length - 1
        visit.call(child, child_prefix, last)
      end
    end

    visit.call(e, "", true)

    widths = nodes.map { |prefix, connector, cls| (prefix + connector + cls).length }
    max_width = widths.max || 0

    lines = [] # : Array[String]
    nodes.zip(widths).each do |node, width|
      prefix, connector, cls, val = node
      left = prefix + connector + cls
      padding = " " * (max_width - (width || raise) + 4)
      lines << (left + padding + val)
    end

    lines.join("\n")
  end
end

# rubocop:enable Naming/PredicateMethod
