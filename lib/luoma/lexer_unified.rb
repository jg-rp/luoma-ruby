# frozen_string_literal: true

require_relative "lexer"

module Luoma
  # A single-pass template tokenizer for the Unified Expression Language with
  # new style comments and no line statements.
  #
  # https://jg-rp.github.io/template-expression-spec/
  class UnifiedLexer < BaseLexer
    RE_FLOAT = /((?:\d+\.\d+(?:[eE][+-]?\d+)?)|(\d+[eE]-\d+))/
    RE_HASHES = /#+/
    RE_INT = /\d+(?:[eE]\+?\d+)?/
    RE_MARKUP_START = /\{[%{#]/
    RE_OUTPUT_END = /\}\}/
    RE_PUNCTUATION = /!=|>=|<=|==|=>|\.{1,3}|[?\[\]|:,()*\/<>=]|([+-](?![}%#]\}))|(%(?!\}))/
    RE_RAW_END = /\{%[+~-]?\s*endraw\s*[+~-]?%\}/
    RE_TAG_END = /%\}/
    RE_TAG_NAME = /[a-z][a-z_0-9]*/
    RE_TRIVIA = /[ \n\r\t]+/
    RE_WHITESPACE_CONTROL = /[+\-~]/
    RE_WORD = /[\u0080-\uFFFFa-zA-Z_][\u0080-\uFFFFa-zA-Z0-9_-]*/

    RE_HASH_COUNT = {
      1 => /[+\-~]?\#\}/,
      2 => /[+\-~]?\#{2}\}/,
      3 => /[+\-~]?\#{3}\}/,
      4 => /[+\-~]?\#{4}\}/,
      5 => /[+\-~]?\#{5}\}/,
      6 => /[+\-~]?\#{6}\}/,
      7 => /[+\-~]?\#{7}\}/
    }.freeze #: Hash[Integer, Regexp]

    # Keywords and symbols that get their own token kind.
    TOKEN_MAP = {
      "true" => :token_true,
      "false" => :token_false,
      "nil" => :token_nil,
      "null" => :token_nil,
      "and" => :token_and,
      "or" => :token_or,
      "orElse" => :token_or_else,
      "not" => :token_not,
      "contains" => :token_contains,
      "in" => :token_in,
      "if" => :token_if,
      "else" => :token_else,
      "?" => :token_question,
      "[" => :token_lbracket,
      "]" => :token_rbracket,
      "|" => :token_pipe,
      "." => :token_dot,
      ".." => :token_double_dot,
      "..." => :token_triple_dot,
      "," => :token_comma,
      ":" => :token_colon,
      "(" => :token_lparen,
      ")" => :token_rparen,
      "=" => :token_assign,
      "<" => :token_lt,
      "<=" => :token_le,
      "<>" => :token_ne,
      ">" => :token_gt,
      ">=" => :token_ge,
      "==" => :token_eq,
      "!=" => :token_ne,
      "=>" => :token_arrow,
      "+" => :token_add,
      "-" => :token_sub,
      "%" => :token_mod,
      "*" => :token_mul,
      "/" => :token_div
    }.freeze #: Hash[String, t_token_kind]

    #: () -> Symbol?
    def scan_markup
      loop do
        case @scanner.scan(RE_MARKUP_START)
        when "{{"
          emit(:token_out_start)
          accept_whitespace_control?
          accept_expression
          skip?(RE_TRIVIA)
          accept_whitespace_control?
          emit(:token_out_end) if @scanner.scan(RE_OUTPUT_END)
        when "{%"
          emit(:token_tag_start)
          accept_whitespace_control?
          skip?(RE_TRIVIA)
          accept_tag
        when "{#"
          accept_comment
        else
          if scan_until?(RE_MARKUP_START)
            emit(:token_text)
          else
            # No more markup. Emit text to end of string.
            @scanner.terminate
            emit(:token_text) if @start < @scanner.pos
            return nil
          end
        end
      end
    end

    #: () -> void
    def accept_tag
      tag_name = @scanner.scan(RE_TAG_NAME)

      case tag_name
      when "raw"
        emit(:token_tag_name)
        skip?(RE_TRIVIA)
        accept_whitespace_control?
        emit(:token_tag_end) if @scanner.scan(RE_TAG_END)
        scan_until?(RE_RAW_END)
        emit(:token_text) if @start < @scanner.pos
      when nil
        # Missing or malformed tag name
        accept_expression
        skip?(RE_TRIVIA)
        accept_whitespace_control?
        emit(:token_tag_end) if @scanner.scan(RE_TAG_END)
      else
        emit(:token_tag_name)
        accept_expression
        skip?(RE_TRIVIA)
        accept_whitespace_control?
        emit(:token_tag_end) if @scanner.scan(RE_TAG_END)
      end
    end

    #: () -> void
    def accept_expression
      loop do
        skip?(RE_TRIVIA)

        if (match = @scanner.scan(RE_PUNCTUATION))
          emit(TOKEN_MAP[match] || :token_unknown)
        elsif (match = @scanner.scan(RE_WORD))
          emit(TOKEN_MAP[match] || :token_ident)
        elsif @scanner.scan(RE_FLOAT)
          emit(:token_float)
        elsif @scanner.scan(RE_INT)
          emit(:token_int)
        else
          case @scanner.peek_byte # steep:ignore
          when 39, 34 # ' or "
            # String literals get their own state because we allow markup
            # delimiters inside quotes.
            accept_string
          when 123 # {
            # Object literals require their own state so we can tell the
            # difference between a closing brace and the start of a closing
            # output delimiter.
            accept_object
          else
            # Non-expression byte or end of input.
            break
          end
        end
      end
    end

    #: () -> void
    def accept_comment
      start_of_delim = @start
      hash_count = 1
      hash_count = (@source.byteslice(@start, @scanner.pos - 1) || raise).size if @scanner.scan(RE_HASHES)
      re = RE_HASH_COUNT[hash_count]

      emit(:token_comment_start)
      wc = accept_whitespace_control?

      if re && scan_until?(re)
        emit(:token_comment)
        accept_whitespace_control?
        @scanner.scan(re)
        emit(:token_comment_end)
      else
        # No closing delimiter. Not a comment.
        @tokens.pop
        @tokens.pop if wc
        @start = start_of_delim
        emit(:token_text)
      end
    end

    #: () -> void
    def accept_string
      # `get_byte` returns a string, `peek_byte` returns an integer :(
      quote = @scanner.get_byte || raise
      byte = quote.ord
      double = quote == '"'

      quote_kind = double ? :token_double_quote : :token_single_quote #: t_token_kind
      unescaped_kind = double ? :token_double_quoted : :token_single_quoted #: t_token_kind
      escaped_kind = double ? :token_double_escaped : :token_single_escaped #: t_token_kind
      current_kind = unescaped_kind #: t_token_kind

      emit(quote_kind)

      if @scanner.peek_byte == byte # steep:ignore
        @scanner.pos += 1
        emit(quote_kind)
        return
      end

      loop do
        case @scanner.get_byte
        when quote
          @scanner.pos -= 1
          emit(current_kind) if @start < @scanner.pos
          @scanner.pos += 1
          emit(quote_kind)
          break
        when "\\"
          @scanner.pos -= 1
          # Emit unescaped segment, if any.
          emit(current_kind) if current_kind == unescaped_kind && @start < @scanner.pos
          @scanner.pos += 2
          current_kind = escaped_kind
        when "$"
          next unless @scanner.peek_byte == 123 # steep:ignore

          @scanner.pos -= 1
          emit(current_kind) if @start < @scanner.pos

          current_kind = unescaped_kind
          @scanner.pos += 2
          emit(:token_interpolation_start)

          accept_expression

          if @scanner.peek_byte == 125 # steep:ignore
            @scanner.pos += 1
            emit(:token_interpolation_end)
          else
            # unclosed interpolation. Let the parser handle it.
            break
          end
        when nil
          # Unclosed string literal. Let the parser handle it.
          break
        end
      end
    end

    #: () -> void
    def accept_object
      @scanner.pos += 1
      emit(:token_lbrace)

      loop do
        case @scanner.peek_byte # steep:ignore
        when 125 # }
          @scanner.pos += 1
          emit(:token_rbrace)
          break
        when nil
          # Unclosed object literal.
          break
        else
          accept_expression
        end
      end
    end

    #: () -> bool
    def accept_whitespace_control?
      if @scanner.scan(RE_WHITESPACE_CONTROL)
        emit(:token_wc)
        true
      else
        false
      end
    end
  end
end
