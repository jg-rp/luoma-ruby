# frozen_string_literal: true

module Luoma
  class UnifiedParser < Parser
    class Precedence
      LOWEST = 1
      COALESCE = 2
      LOGICAL_OR = 3
      LOGICAL_AND = 4
      LOGICAL_NOT = 5
      COMPARISON = 6
      MEMBERSHIP = 6
      PIPE = 7
      FILTER_ARG = 8
      ADD = 9
      MUL = 10
      NEG = 11
    end

    PRECEDENCES = {
      token_or_else: Precedence::COALESCE,
      token_or: Precedence::LOGICAL_OR,
      token_and: Precedence::LOGICAL_AND,
      token_not: Precedence::LOGICAL_NOT,
      token_eq: Precedence::COMPARISON,
      token_ne: Precedence::COMPARISON,
      token_lt: Precedence::COMPARISON,
      token_le: Precedence::COMPARISON,
      token_gt: Precedence::COMPARISON,
      token_ge: Precedence::COMPARISON,
      token_in: Precedence::MEMBERSHIP,
      token_contains: Precedence::MEMBERSHIP,
      token_add: Precedence::ADD,
      token_sub: Precedence::ADD,
      token_mul: Precedence::MUL,
      token_div: Precedence::MUL,
      token_mod: Precedence::MUL,
      token_pipe: Precedence::PIPE
    }.freeze #: Hash[t_token_kind, Integer]

    INFIX_OPERATORS = {
      token_or_else: CoalesceExpression,
      token_or: OrExpression,
      token_and: AndExpression,
      token_eq: EqExpression,
      token_ne: NeExpression,
      token_lt: LtExpression,
      token_le: LeExpression,
      token_gt: GtExpression,
      token_ge: GeExpression,
      token_in: InExpression,
      token_contains: ContainsExpression,
      token_add: AddExpression,
      token_sub: SubExpression,
      token_mul: MulExpression,
      token_div: DivExpression,
      token_mod: ModExpression,
      token_pipe: nil
    }.freeze #: Hash[t_token_kind, untyped]

    TERMINATE_EXPRESSION = Set[
      :token_wc,
      :token_out_end,
      :token_tag_end,
      :token_text,
      :token_if,
      :token_else,
      :token_rparen,
      :token_eoi,
      :token_interpolation_end
    ].freeze #: Set[t_token_kind]

    TERMINATE_FILTER = Set[
        :token_wc,
        :token_out_end,
        :token_tag_end,
        :token_text,
        :token_if,
        :token_else,
        :token_rparen,
        :token_pipe,
        :token_eoi,
        :token_interpolation_end,
        :token_or_else,
        :token_or,
        :token_and,
        :token_eq,
        :token_ne,
        :token_lt,
        :token_le,
        :token_gt,
        :token_ge,
        :token_in,
        :token_contains
    ].freeze #: Set[t_token_kind]

    PATH_PUNCTUATION = Set[
        :token_dot,
        :token_lbracket
    ].freeze #: Set[t_token_kind]

    STRING_LITERAL_KINDS = Set[
      :token_single_escaped,
      :token_single_quoted,
      :token_double_escaped,
      :token_double_quoted
    ].freeze #: Set[t_token_kind]

    PATH_ROOT_KINDS = Set[
      :token_ident,
      :token_false,
      :token_true,
      :token_null,
      :token_nil
    ].freeze #: Set[t_token_kind]

    KEYWORD_ARGUMENT_DELIMITERS = Set[
      :token_colon,
      :token_assign
  ].freeze #: Set[t_token_kind]

    #: (?require_commas: bool?) -> Array[Expression | KeywordArgument]
    def parse_arguments(require_commas: nil)
      args = [] #: Array[Expression | KeywordArgument]

      loop do
        kind_ = kind
        break if TERMINATE_EXPRESSION.include?(kind_)

        if kind_ == :token_ident && KEYWORD_ARGUMENT_DELIMITERS.include?(peek.first)
          # A named argument
          name = parse_ident
          eat_one_of(KEYWORD_ARGUMENT_DELIMITERS)
          args << KeywordArgument.new(name.token, name, parse_expression)
        else
          args << parse_expression
        end

        kind_ = kind
        if require_commas && !TERMINATE_EXPRESSION.include?(kind_)
          eat(:token_comma)
        elsif kind_ == :token_comma
          @pos += 1
        end
      end

      args
    end

    #: (?stop: Set[String]?) -> t_block
    def parse_block(stop: nil)
      nodes = [] #: t_block

      loop do
        token = self.next

        case token.first
        when :token_text
          nodes << @env.trim(
            Luoma.get_token_value(token, @source),
            @whitespace_control_carry,
            peek_whitespace_control
          )
        when :token_out_start
          nodes << parse_output
        when :token_tag_start
          if stop&.include?(peek_tag_name)
            @pos -= 1
            break
          end

          nodes << parse_tag
        when :token_comment_start
          nodes << parse_comment
        when :token_eoi
          break
        else
          raise TemplateSyntaxError.new(
            "unexpected #{Luoma::TOKEN_KIND_MAP[token.first].inspect}",
            token,
            @source,
            @template_name
          )
        end
      end

      nodes
    end

    #: (?precedence: Integer) -> Expression
    def parse_expression(precedence: Precedence::LOWEST)
      expr = parse_primary(precedence: precedence)
      expr = parse_ternary(expr) if kind == :token_if
      expr
    end

    #: () -> Name
    def parse_ident
      token = eat(:token_ident)

      if PATH_PUNCTUATION.include?(kind)
        raise TemplateSyntaxError.new(
          "expected an identifier, found a path",
          token,
          @source,
          @template_name
        )
      end

      Name.new(token, Luoma.get_token_value(token, @source))
    end

    #: (?require_commas: bool?) -> Array[KeywordArgument]
    def parse_keyword_arguments(require_commas: nil)
      args = [] #: Array[KeywordArgument]

      loop do
        kind_ = kind
        break if TERMINATE_EXPRESSION.include?(kind_)

        name = parse_ident
        eat_one_of(KEYWORD_ARGUMENT_DELIMITERS)
        args << KeywordArgument.new(name.token, name, parse_expression)

        kind_ = kind
        if require_commas && !TERMINATE_EXPRESSION.include?(kind_)
          eat(:token_comma)
        elsif kind_ == :token_comma
          @pos += 1
        end
      end

      args
    end

    #: () -> t_block
    def parse_line_statements
      block = [] #: t_block

      loop do
        token = current
        kind_ = token.first

        if kind_ == :token_tag_start
          @pos += 1
          block << parse_tag
        elsif kind_ == :token_wc || kind_ == :token_tag_end
          break
        else
          raise TemplateSyntaxError.new(
            "unexpected #{Luoma::TOKEN_KIND_MAP[kind_]} (#{Luoma.get_token_value(token, @source).inspect})",
            token,
            @source,
            @template_name
          )
        end
      end

      block
    end

    # Parse an identifier, possibly surrounded by quotes.
    #: () -> Name
    def parse_name
      case kind
      when :token_ident
        parse_ident
      when :token_single_quote, :token_double_quote
        expr = parse_string_literal

        if expr.segments.length > 1 || !expr.segments.first.is_a?(String)
          raise TemplateSyntaxError.new(
            "expected a string or identifier",
            current,
            @source,
            @template_name
          )
        end

        Name.new(expr.token, expr.segments[0]) # steep:ignore
      else
        raise TemplateSyntaxError.new(
          "expected a string or identifier",
          current,
          @source,
          @template_name
        )
      end
    end

    #: (?require_commas: bool?) -> Array[Expression]
    def parse_positional_arguments(require_commas: nil)
      args = [] #: Array[Expression]

      loop do
        break if TERMINATE_EXPRESSION.include?(kind)

        args << parse_expression

        kind_ = kind
        if require_commas && !TERMINATE_EXPRESSION.include?(kind_)
          eat(:token_comma)
        elsif kind_ == :token_comma
          @pos += 1
        end
      end

      args
    end

    #: () -> StringLiteral
    def parse_string_literal
      token = self.next

      # Empty string?
      return StringLiteral.new(token, "", eat(token.first)) if kind == token.first

      StringLiteral.new(
        token,
        Luoma.get_token_value(eat_one_of(STRING_LITERAL_KINDS), @source),
        eat(token.first)
      )
    end

    protected

    #: (?precedence: Integer) -> Expression
    def parse_primary(precedence: Precedence::LOWEST)
      left = case kind
             when :token_single_quote, :token_double_quote
               parse_string_literal
             when :token_ident
               parse_path
             when :token_lbracket
               parse_array_or_path
             when :token_lbrace
               parse_object_literal
             when :token_lparen
               parse_lambda_range_or_group
             when :token_not, :token_add, :token_sub
               parse_prefix
             when :token_true
               parse_true_literal
             when :token_false
               parse_false_literal
             when :token_null, :token_nil
               parse_null_literal
             when :token_int
               parse_int_literal
             when :token_float
               parse_float_literal
             else
               token = current
               raise TemplateSyntaxError.new(
                 "unexpected #{Luoma::TOKEN_KIND_MAP[token.first].inspect}",
                 token,
                 @source,
                 @template_name
               )
             end

      loop do
        kind_ = kind
        break if (PRECEDENCES[kind_] || Precedence::LOWEST) < precedence || !INFIX_OPERATORS.include?(kind_)

        left = parse_infix(left)
      end

      left
    end

    #: (Expression) -> Expression
    def parse_ternary(consequence)
      eat(:token_if)
      condition = parse_primary
      alternative = if kind == :token_else
                      @pos += 1
                      parse_primary
                    end

      TernaryExpression.new(consequence.token, consequence, condition, alternative)
    end

    #: () -> Markup
    def parse_output
      token = @tokens[@pos - 1]
      skip_whitespace_control
      expr = parse_expression
      carry_whitespace_control
      eat(:token_out_end)
      OutputStatement.new(token, expr)
    end

    #: () -> Markup
    def parse_tag
      skip_whitespace_control
      token = eat(:token_tag_name, message: "missing tag name")
      tag_name = Luoma.get_token_value(token, @source)
      tag = @env.tags[tag_name]

      unless tag
        raise TemplateSyntaxError.new(
          "unexpected tag #{Luoma.get_token_value(token, @source)}",
          token,
          @source,
          @template_name
        )
      end

      tag.parse(token, tag_name, self)
    end

    #: () -> Variable
    def parse_path
      token = current

      root = if PATH_ROOT_KINDS.include?(token.first)
               @pos += 1
               Name.new(token, Luoma.get_token_value(token, @source))
             else
               eat(:token_lbracket)
               if kind == :token_ident
                 path = parse_path
                 eat(:token_rbracket)
                 path
               else
                 parse_string_literal.with(eat(:token_rbracket))
               end
             end

      Variable.new(token, root, parse_path_segments)
    end

    #: () -> Array[t_path_segment]
    def parse_path_segments
      segments = [] #: Array[t_path_segment]

      loop do
        case kind
        when :token_lbracket
          segments << parse_bracketed_segment
        when :token_dot
          @pos += 1
          token = eat(:token_ident)
          segments << Name.new(token, Luoma.get_token_value(token, @source))
        else
          break
        end
      end

      segments
    end

    #: () -> t_path_segment
    def parse_bracketed_segment
      eat(:token_lbracket)
      token = self.next

      case token.first
      when :token_int
        IndexSelector.new(
          token, Luoma.get_token_value(token, @source).to_i
        ).with(eat(:token_rbracket))
      when :token_ident, :token_blank, :token_empty, :token_false, :token_true, :token_null, :token_nil
        @pos -= 1
        path = parse_path
        eat(:token_rbracket)
        path
      when :token_double_quote, :token_single_quote
        @pos -= 1
        parse_string_literal.with(eat(:token_rbracket))
      when :token_rbracket
        raise TemplateSyntaxError.new(
          "empty bracketed segment",
          token,
          @source,
          @template_name
        )
      else
        raise TemplateSyntaxError.new(
          "expected an integer, identifier or string",
          token,
          @source,
          @template_name
        )
      end
    end

    #: () -> Expression
    def parse_array_or_path
      raise "TODO:"
    end

    #: (t_token, Expression) -> Expression
    def parse_partial_array(token, first)
      raise "TODO:"
    end

    #: () -> ObjectLiteral
    def parse_object_literal
      raise "TODO:"
    end

    #: () -> Item | Spread
    def parse_object_item
      raise "TODO:"
    end

    #: () -> Expression
    def parse_lambda_range_or_group
      raise "TODO:"
    end

    #: (Expression) -> Lambda
    def parse_partial_lambda(expr)
      raise "TODO:"
    end

    #: () -> Expression
    def parse_prefix
      raise "TODO:"
    end

    #: () -> Expression
    def parse_range_literal
      token = eat(:token_lparen)
      start = parse_expression
      eat(:token_double_dot)
      stop = parse_expression
      eat(:token_rparen)
      RangeLiteral.new(token, start, stop)
    end

    #: () -> Expression
    def parse_true_literal
      token = self.next
      if PATH_PUNCTUATION.include?(kind)
        @pos -= 1
        parse_path
      else
        BooleanLiteral.new(token, true)
      end
    end

    #: () -> Expression
    def parse_false_literal
      token = self.next
      if PATH_PUNCTUATION.include?(kind)
        @pos -= 1
        parse_path
      else
        BooleanLiteral.new(token, false)
      end
    end

    #: () -> Expression
    def parse_null_literal
      token = self.next
      if PATH_PUNCTUATION.include?(kind)
        @pos -= 1
        parse_path
      else
        NullLiteral.new(token)
      end
    end

    #: () -> Expression
    def parse_int_literal
      token = self.next
      IntegerLiteral.new(token, Luoma.get_token_value(token, @source).to_i)
    end

    #: () -> Expression
    def parse_float_literal
      token = self.next
      FloatLiteral.new(token, Float(Luoma.get_token_value(token, @source)))
    end

    #: (Expression) -> FilteredExpression
    def parse_filter(token, left)
      name = parse_ident

      if TERMINATE_FILTER.include?(kind)
        # No arguments
        return FilteredExpression.new(
          token,
          left,
          Filter.new(
            name.token,
            name,
            [],
            []
          )
        )
      end

      eat(:token_colon, message: "missing colon or pipe")
      args = [] #: Array[Expression]
      kwargs = [] #: Array[KeywordArgument]

      loop do
        kind_ = kind
        break if TERMINATE_FILTER.include?(kind_)

        if kind_ == :token_ident
          peek_kind = peek.first
          if KEYWORD_ARGUMENT_DELIMITERS.include?(peek_kind)
            # A keyword argument
            param = parse_ident
            eat_one_of(KEYWORD_ARGUMENT_DELIMITERS)
            value = parse_expression(precedence: Precedence::FILTER_ARG)
            kwargs << KeywordArgument.new(param.token, param, value)
          elsif peek_kind == :token_arrow
            # A positional argument that is an arrow function with a single
            # parameter.
            args << parse_lambda
          else
            # A positional argument that is a variable or path
            args << parse_expression(precedence: Precedence::FILTER_ARG)
          end
        else
          break if TERMINATE_FILTER.include?(kind_)

          args << parse_expression(precedence: Precedence::FILTER_ARG)
        end

        break if TERMINATE_FILTER.include?(kind)

        eat(:token_comma, message: "missing comma or pipe")
      end

      FilteredExpression.new(
        token,
        left,
        Filter.new(
          name.token,
          name,
          args,
          kwargs
        )
      )
    end

    #: () -> Lambda
    def parse_lambda
      raise "TODO:"
    end

    #: (Expression) -> Expression
    def parse_infix(left)
      op_token = self.next
      kind_ = op_token.first

      return parse_filter(op_token, left) if kind == :token_pipe

      right = parse_expression(precedence: PRECEDENCES[kind_] || Precedence::LOWEST)
      INFIX_OPERATORS[kind_].new(op_token, left, right)
    end
  end
end
