# frozen_string_literal: true

module Luoma
  class LegacyParser < Parser
    class Precedence
      LOWEST = 1
      LOGICAL_RIGHT = 3
      RELATIONAL = 4
      MEMBERSHIP = 5
      PREFIX = 9
    end

    PRECEDENCES = {
      token_and: Precedence::LOGICAL_RIGHT,
      token_or: Precedence::LOGICAL_RIGHT,
      token_not: Precedence::PREFIX,
      token_rparen: Precedence::LOWEST,
      token_contains: Precedence::MEMBERSHIP,
      token_eq: Precedence::RELATIONAL,
      token_lt: Precedence::RELATIONAL,
      token_gt: Precedence::RELATIONAL,
      token_ne: Precedence::RELATIONAL,
      token_lg: Precedence::RELATIONAL,
      token_le: Precedence::RELATIONAL,
      token_ge: Precedence::RELATIONAL
    }.freeze #: Hash[t_token_kind, Integer]

    INFIX_OPERATORS = {
      token_and: AndExpression,
      token_or: OrExpression,
      token_contains: ContainsExpression,
      token_eq: EqExpression,
      token_lt: LtExpression,
      token_gt: GtExpression,
      token_ne: NeExpression,
      token_lg: NeExpression,
      token_le: LeExpression,
      token_ge: GeExpression
    }.freeze #: Hash[t_token_kind, untyped]

    TERMINATE_FILTER = Set[
        :token_wc,
        :token_out_end,
        :token_tag_end,
        :token_text,
        :token_rparen,
        :token_eoi,
        :token_pipe
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

    #: (?require_commas: bool?) -> Array[Expression | KeywordArgument]
    def parse_arguments(require_commas: nil)
      args = [] #: Array[Expression | KeywordArgument]

      loop do
        kind_ = kind
        break if TERMINATE_EXPRESSION.include?(kind_)

        if kind_ == :token_ident && peek.first == :token_colon
          # A named argument
          name = parse_ident
          eat(:token_colon)
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

    #: (?precedence: Integer, ?infix: bool?) -> Expression
    def parse_expression(precedence: Precedence::LOWEST, infix: nil)
      left = case kind
             when :token_single_quote, :token_double_quote
               parse_string_literal
             when :token_ident, :token_lbracket
               parse_path
             when :token_lparen
               parse_range_literal
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
             when :token_blank
               parse_blank
             when :token_empty
               parse_empty
             else
               token = current
               raise TemplateSyntaxError.new(
                 "unexpected #{Luoma::TOKEN_KIND_MAP[token.first].inspect}",
                 token,
                 @source,
                 @template_name
               )
             end

      return left unless infix

      loop do
        kind_ = kind
        break if (PRECEDENCES[kind_] || Precedence::LOWEST) < precedence || !INFIX_OPERATORS.include?(kind_)

        left = parse_infix(left)
      end

      left
    end

    # Parse an expression with optional filters.
    #: (?precedence: Integer, ?infix: bool?) -> Expression
    def parse_filtered_expression(precedence: Precedence::LOWEST, infix: nil)
      expr = parse_expression(precedence: precedence, infix: infix)
      expr = parse_filters(expr) if kind == :token_pipe
      expr
    end

    #: () -> Name
    def parse_ident
      token = eat(:token_ident)

      if PATH_PUNCTUATION.include?(kind)
        raise TemplateSyntaxError.new(
          "expected and identifier, found a path",
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
        eat(:token_colon)
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
        Name.new(expr.token, expr.value)
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

    #: () -> Markup
    def parse_output
      token = @tokens[@pos - 1]
      skip_whitespace_control
      expr = parse_filtered_expression
      carry_whitespace_control
      eat(:token_out_end)
      OutputStatement.new(token, expr)
    end

    #: () -> Markup
    def parse_tag
      skip_whitespace_control
      token = eat(:token_tag_name, message: "missing tag name")
      tag = @env.tags[Luoma.get_token_value(token, @source)]

      unless tag
        raise TemplateSyntaxError.new(
          "unexpected tag #{Luoma.get_token_value(token, @source)}",
          token,
          @source,
          @template_name
        )
      end

      tag.parse(token, self)
    end

    #: () -> Expression
    def parse_path
      raise "TODO:"
    end

    #: () -> Array[t_path_segment]
    def parse_path_segments
      raise "TODO:"
    end

    #: () -> t_path_segment
    def parse_bracketed_segment
      raise "TODO:"
    end

    #: () -> Expression
    def parse_range_literal
      raise "TODO:"
    end

    #: () -> Expression
    def parse_true_literal
      raise "TODO:"
    end

    #: () -> Expression
    def parse_false_literal
      raise "TODO:"
    end

    #: () -> Expression
    def parse_null_literal
      raise "TODO:"
    end

    #: () -> Expression
    def parse_int_literal
      raise "TODO:"
    end

    #: () -> Expression
    def parse_float_literal
      raise "TODO:"
    end

    #: () -> Expression
    def parse_blank
      raise "TODO"
    end

    #: () -> Expression
    def parse_empty
      raise "TODO:"
    end

    #: (Expression) -> FilteredExpression
    def parse_filters(left)
      raise "TODO:"
    end

    #: (Expression) -> FilteredExpression
    def parse_filter(left)
      raise "TODO:"
    end

    #: (Expression) -> Expression
    def parse_infix(left)
      raise "TODO:"
    end
  end
end
