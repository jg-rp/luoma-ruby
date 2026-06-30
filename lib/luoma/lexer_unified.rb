# frozen_string_literal: true

require_relative "lexer"

module Luoma
  # A single-pass template tokenizer for the Unified Expression Language.
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
        emit(:token_text) if scan_until?(RE_RAW_END)
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
          next_byte = @scanner.peek_byte # steep:ignore

          if next_byte == 39 || next_byte == 34
            accept_string
          elsif next_byte == 125
            # Object literals require their own state so we can tell the
            # difference between a closing brace and the start of a closing
            # output delimiter.
            accept_object
          else
            @scanner.pos += 1
            emit(:token_unknown)
          end
        end
      end
    end

    #: () -> void
    def accept_comment
      raise "TODO:"
    end

    #: () -> void
    def accept_string
      raise "TODO:"
    end

    #: () -> void
    def accept_object
      raise "TODO:"
    end

    #: () -> bool
    def accept_whitespace_control?
      if @scanner.peek_byte == 45 # steep:ignore
        @scanner.pos += 1
        emit(:token_wc)
        true
      else
        false
      end
    end
  end
end
