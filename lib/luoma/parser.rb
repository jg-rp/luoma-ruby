# frozen_string_literal: true

module Luoma
  class Parser
    attr_reader :source, :template_name, :env

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
      if kind == :token_wc
        @whitespace_control_carry = "-"
        @pos += 1
      else
        @whitespace_control_carry = nil
      end
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
      token = @tokens[@pos] || @eoi
      unless token.first == kind
        kind_ = Luoma::TOKEN_KIND_MAP[token.first]
        value = Luoma.get_token_value(token, @source).inspect
        raise TemplateSyntaxError.new(
          message || "unexpected #{kind_} (#{value})",
          token,
          @source,
          @template_name
        )
      end

      @pos += 1
      token
    end

    #: (String) -> t_token
    def eat_empty_tag(name)
      eat(:token_tag_start, message: "expected tag #{name}")
      @pos += 1 if kind == :token_wc # steep:ignore
      token = eat(:token_tag_name, message: "expected tag #{name}")
      got = Luoma.get_token_value(token, @source)

      unless got == name
        raise TemplateSyntaxError.new(
          "unexpected tag #{got.inspect}",
          token,
          @source,
          @template_name
        )
      end

      carry_whitespace_control
      eat(:token_tag_end, message: "expected a closing tag delimiter")
      token
    end

    #: (Set[t_token_kind]) -> t_token
    def eat_one_of(kinds)
      token = @tokens[@pos] || @eoi
      unless kinds.include?(token.first)
        kind_ = Luoma::TOKEN_KIND_MAP[token.first]
        value = Luoma.get_token_value(token, @source).inspect
        raise TemplateSyntaxError.new(
          "unexpected #{kind_} (#{value})",
          token,
          @source,
          @template_name
        )
      end

      @pos += 1
      token
    end

    #: (String) -> t_token
    def eat_tag(name)
      eat(:token_tag_start, message: "expected tag #{name}")
      @pos += 1 if kind == :token_wc # steep:ignore
      token = eat(:token_tag_name, message: "expected tag #{name}")
      got = Luoma.get_token_value(token, @source)

      unless got == name
        raise TemplateSyntaxError.new(
          "unexpected tag #{got.inspect}",
          token,
          @source,
          @template_name
        )
      end

      # Ignore everything between the tag name and the closing tag delimiter.
      @pos += 1 until TERMINATE_EXPRESSION.include?(kind)

      carry_whitespace_control
      eat(:token_tag_end, message: "expected a closing tag delimiter")
      token
    end

    # Raise an error if we're not at the start of an expression.
    #: () -> void
    def expect_expression
      if TERMINATE_EXPRESSION.include?(kind)
        raise TemplateSyntaxError.new(
          "missing expression",
          current,
          @source,
          @template_name
        )
      end
    end

    #: (?require_commas: bool?) -> Array[Expression | KeywordArgument]
    def parse_arguments(require_commas: nil)
      raise "not implemented"
    end

    #: (?stop: Set[String]?) -> t_block
    def parse_block(stop: nil)
      raise "not implemented"
    end

    #: (?precedence: Integer) -> Expression
    def parse_expression(precedence: 1)
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
      token = current
      token = peek if token.first == :token_wc

      unless token.first == :token_tag_name
        raise TemplateSyntaxError.new(
          "missing tag name",
          token,
          @source,
          @template_name
        )
      end

      Luoma.get_token_value(token, @source)
    end

    #: () -> String?
    def peek_whitespace_control
      token = peek
      Luoma.get_token_value(token, @source) if token.first == :token_wc
    end

    #: () -> void
    def skip_whitespace_control
      @pos += 1 if kind == :token_wc
    end

    # Return `true` if we're at the start of a tag named `name`.
    #: (String) -> bool
    def tag?(name)
      token = peek
      token = peek(2) if token.first == :token_wc

      token.first == :token_tag_name && Luoma.get_token_value(token, @source) == name
    end

    # Return a tag name if we're at the start of a tag and that tag's name is
    # in `names`.
    #: (Set[String]) -> String?
    def tags(names)
      token = peek
      token = peek(2) if token.first == :token_wc

      return unless token.first == :token_tag_name

      name = Luoma.get_token_value(token, @source)
      name if names.include?(name)
    end
  end
end
