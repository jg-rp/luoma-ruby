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

    #: (RenderContext) -> Array[_Traversable]
    def children(context)
      raise "not implemented"
    end

    #: () -> String
    def to_s
      raise "not implemented"
    end
  end

  class FilteredExpression < Expression
    #: (t_token, Expression, Filter) -> void
    def initialize(token, left, filter)
      super(token)
      @left = left
      @filter = filter
      @span = Luoma.span(token, filter.span)
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

        # Pass the input value through
        return @left.evaluate(context)
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
        @token,
        context.template.source,
        context.template.name
      )
    end

    #: (RenderContext) -> Array[_Traversable]
    def children(context)
      [@left, @filter]
    end

    #: () -> String
    def to_s
      "#{@left} | #{@filter}"
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

    #: (RenderContext) -> Array[_Traversable]
    def children(context)
      [@left, @right]
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

    #: (RenderContext) -> Array[_Traversable]
    def children(context)
      if @root.is_a?(Variable)
        [@root, *@segments.grep(Variable)]
      else
        @segments.filter.grep(Variable)
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

    #: (RenderContext) -> Array[_Traversable]
    def children(context)
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

  class StringLiteral < Expression
    attr_reader :value

    #: (t_token, Integer, t_token)
    def initialize(token, value, end_token)
      super(token)
      @value = value
      @span = Luoma.span(token, end_token)
    end

    #: (RenderContext) -> untyped
    def evaluate(context)
      context.env.auto_escape ? HTMLSafeDrop.from(@value) : @value
    end

    #: (RenderContext) -> Array[_Traversable]
    def children(context)
      []
    end

    #: () -> String
    def to_s
      @token.first == :token_double_quoted ? "\"#{@value}\"" : "'#{@value}'"
    end

    def with(token)
      @span = Luoma.span(@token, token)
      self
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

    #: (RenderContext) -> Array[_Traversable]
    def children(context)
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

    #: (RenderContext) -> Array[_Traversable]
    def children(context)
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

    #: (RenderContext) -> Array[_Traversable]
    def children(context)
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

    #: (RenderContext) -> Array[_Traversable]
    def children(context)
      []
    end

    #: () -> String
    def to_s
      ""
    end
  end

  class Blank < Expression
    #: (RenderContext) -> untyped
    def evaluate(context)
      Luoma::BLANK
    end

    #: (RenderContext) -> Array[_Traversable]
    def children(context)
      []
    end

    #: () -> String
    def to_s
      ""
    end
  end

  class Empty < Expression
    #: (RenderContext) -> untyped
    def evaluate(context)
      Luoma::EMPTY
    end

    #: (RenderContext) -> Array[_Traversable]
    def children(context)
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
      start = context.env.to_i(@start.evaluate(context), context, @span)
      stop = context.env.to_i(@stop.evaluate(context), context, @span)
      RangeDrop.new(start, stop)
    end

    #: (RenderContext) -> Array[_Traversable]
    def children(context)
      [@start, @stop]
    end

    #: () -> String
    def to_s
      "(#{@start}..#{@stop})"
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

    def children(context)
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

    def children(context)
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

    #: (RenderContext) -> Array[_Traversable]
    def children(context)
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
end

# rubocop:enable Naming/PredicateMethod
