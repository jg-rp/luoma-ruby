# frozen_string_literal: true

module Luoma
  class Parser
    TERMINATE_EXPRESSION = Set.new(%i[
                                     token_wc
                                     token_out_end
                                     token_tag_end
                                     token_text
                                     token_rparen
                                     token_eoi
                                     token_if
                                     token_else
                                     token_interpolation_end
                                   ]).freeze #: Set[t_token_kind]

    #: (Environment, String, String, Array[t_token]) -> t_block
    def self.parse(env, source, template_name, tokens)
      new(env, source, template_name, tokens).parse_block
    end

    #: (Environment, String, String, Array[t_token]) -> void
    def initialize(env, source, template_name, tokens)
      @env = env
      @source = source
      @template_name = template_name
      @tokens = tokens

      @pos = 0
      @eoi = [:token_eoi, source.length, source.length]
      @whitespace_control_carry = nil #: "-" | "+" | "~" | nil
    end

    #: () -> void
    def carry_whitespace_control
      raise "TODO:"
    end

    #: () -> t_token
    def current
      @tokens[@pos] || @eoi
    end

    #: () -> t_token_kind
    def kind
      (@tokens[@pos] || @eoi).first #: t_token_kind
    end

    #: () -> String
    def current_value
      Luoma.get_token_value(@tokens[@pos] || @eoi, @source)
    end

    #: () -> t_token
    def next
      token = @tokens[@pos] || @eoi
      @pos += 1
      token
    end

    def peek(offset = 1)
      @tokens[@pos + offset] || @eoi
    end

    #: (t_token_kind, ?message: String?) -> t_token
    def eat(kind, message: nil)
      raise "TODO"
    end

    #: (String) -> t_token
    def eat_empty_tag(name)
      raise "TODO:"
    end

    #: (Set[t_token_kind]) -> t_token
    def eat_one_of(kinds)
      raise "TODO:"
    end

    #: (String) -> t_token
    def eat_tag(name)
      raise "TODO:"
    end

    # Raise an error if we're not at the start of an expression.
    #: () -> void
    def expect_expression
      raise "TODO:"
    end

    #: (?require_commas: bool?) -> Array[Expression | KeywordArgument]
    def parse_arguments(require_commas: nil)
      raise "not implemented"
    end

    #: (?end: Set[String]?) -> t_block
    def parse_block(end: nil)
      raise "not implemented"
    end

    #: (?precedence: Integer?, ?infix: bool?) -> Expression
    def parse_expression(precedence: nil, infix: nil)
      raise "not implemented"
    end

    # Parse an expression with optional filters.
    #: (?precedence: Integer?, ?infix: bool?) -> Expression
    def parse_filtered_expression(precedence: nil, infix: nil)
      raise "not implemented"
    end

    #: () -> Name
    def parse_ident
      raise "not implemented"
    end

    #: (?require_commas: bool?) -> Array[KeywordArgument]
    def parse_keyword_arguments(require_commas: nil)
      raise "not implemented"
    end

    #: () -> t_block
    def parse_line_statements
      raise "not implemented"
    end

    # Parse an identifier, possibly surrounded by quotes.
    #: () -> Name
    def parse_name
      raise "not implemented"
    end

    #: (?require_commas: bool?) -> Array[Expression]
    def parse_positional_arguments(require_commas: nil)
      raise "not implemented"
    end

    #: () -> StringLiteral
    def parse_string_literal
      raise "not implemented"
    end

    #: () -> String
    def peek_tag_name
      raise "TODO:"
    end

    #: () -> String?
    def peek_whitespace_control
      raise "TODO:"
    end

    #: () -> void
    def skip_whitespace_control
      raise "TODO:"
    end

    # Return `true` if we're at the start of a tag named `name`.
    #: (String) -> bool
    def tag?(name)
      raise "TODO:"
    end

    # Return `true` if we're at the start of a tag and that tag's name is in
    # `names`.
    #: (Set[String]) -> bool
    def tags?(names)
      raise "TODO:"
    end
  end
end
