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
      token_and: Precedence::LOGICAL_AND,
      token_or: Precedence::LOGICAL_OR,
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
    }.freeze

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
    }.freeze

    TERMINATE_FILTER = Set[
        :token_wc,
        :token_out_end,
        :token_tag_end,
        :token_text,
        :token_rparen,
        :token_eoi,
        :token_pipe
    ].freeze

    PATH_PUNCTUATION = Set[
        :token_dot,
        :token_lbracket
    ].freeze

    STRING_LITERAL_KINDS = Set[
      :token_single_escaped,
      :token_single_quoted,
      :token_double_escaped,
      :token_double_quoted
    ].freeze

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
          if stop && stop.include?(peek_tag_name)
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

    #: (?precedence: Integer?, ?infix: bool?) -> Expression
    def parse_expression(precedence: nil, infix: nil)
      raise "TODO:"
    end

    # Parse an expression with optional filters.
    #: (?precedence: Integer?, ?infix: bool?) -> Expression
    def parse_filtered_expression(precedence: nil, infix: nil)
      raise "TODO:"
    end

    #: () -> Name
    def parse_ident
      raise "TODO:"
    end

    #: (?require_commas: bool?) -> Array[KeywordArgument]
    def parse_keyword_arguments(require_commas: nil)
      raise "TODO:"
    end

    #: () -> t_block
    def parse_line_statements
      raise "TODO:"
    end

    # Parse an identifier, possibly surrounded by quotes.
    #: () -> Name
    def parse_name
      raise "TODO:"
    end

    #: (?require_commas: bool?) -> Array[Expression]
    def parse_positional_arguments(require_commas: nil)
      raise "TODO:"
    end

    #: () -> StringLiteral
    def parse_string_literal
      raise "TODO:"
    end

    protected

    #: () -> Expression
    def parse_blank
      raise "TODO"
    end

    #: () -> Markup
    def parse_output
      raise "TODO"
    end

    #: () -> Markup
    def parse_tag
      raise "TODO"
    end
  end
end
