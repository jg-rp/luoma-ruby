# frozen_string_literal: true

require_relative "lexer"

module Luoma
  # A single-pass template tokenizer that matches Shopify/liquid v5.12.0 strict
  # mode syntax.
  #
  # We use lookahead and byte offset limits to achieve behavior equivalent to
  # Shopify's two-pass tokenizer/parser.
  class LegacyLexer < BaseLexer
    RE_MARKUP = /\{[%{]/
    RE_OUT_END = /-?(\}\}?|%\}(?!\}))/
    RE_TAG_END = /-?%\}/
    RE_TRIVIA = /[ \n\r\t\f]+/
    RE_LINE_TRIVIA = /[ \t\f\r]+/
    RE_TAG_NAME = /#|[a-zA-Z0-9_]+/
    RE_PUNCTUATION = /[.!=<>]{1,2}|[?\[\]|:,()]/
    RE_IDENT = /[a-zA-Z_][a-zA-Z0-9_-]*\??/
    RE_FLOAT = /-?\d+\.\d+/
    RE_INT = /-?\d+/
    RE_COMMENT_SEGMENT = /\{%-?\s*(comment|raw|endcomment|endraw).*?-?%\}/m
    RE_LINE_COMMENT_SEGMENT = /\n\s*(comment|endcomment).*/
    RE_END_DOC = /\{%-?\s*enddoc\s*-?%\}/
    RE_END_RAW = /\{%-?\s*endraw\s*-?%\}/
    RE_SINGLE_QUOTE = /'/
    RE_DOUBLE_QUOTE = /"/
    RE_NEWLINE = /\n/

    # Keywords and symbols that get their own token kind.
    TOKEN_MAP = {
      "true" => :token_true,
      "false" => :token_false,
      "nil" => :token_nil,
      "null" => :token_nil,
      "and" => :token_and,
      "or" => :token_or,
      "contains" => :token_contains,
      "in" => :token_in,
      "blank" => :token_blank,
      "empty" => :token_empty,
      "[" => :token_lbracket,
      "]" => :token_rbracket,
      "|" => :token_pipe,
      "." => :token_dot,
      ".." => :token_double_dot,
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
      "#" => :token_hash
    }.freeze #: Hash[String, t_token_kind]

    #: () -> Symbol?
    def scan_markup
      limit = nil #: Integer?

      loop do
        case scan(RE_MARKUP)
        when "{{"
          # Output statements can be closed by `}}`, `}` or `%}`.
          # Markup delimiters are greedy and not string literal aware.
          limit = index(RE_OUT_END)

          if limit.nil?
            # Not markup and no more '}'. Emit text to end of string.
            @scanner.terminate
            emit(:token_text)
            return nil
          end

          emit(:token_out_start)
          accept_whitespace_control
          accept_expression(limit)
          skip(RE_TRIVIA)
          accept_whitespace_control
          scan(RE_OUT_END)
          emit(:token_out_end)
        when "{%"
          # Tags must be closed by `%}`.
          # Markup delimiters are greedy and not string literal aware.
          limit = index(RE_TAG_END)

          if limit.nil?
            # No more `%}`, but there could be `{{` and `}}`
            if scan_until(RE_MARKUP)
              emit(:token_text)
            else
              # No more markup. Emit text to end of string.
              @scanner.terminate
              emit(:token_text) if @start < @scanner.pos
              return nil
            end
          else
            emit(:token_tag_start)
            accept_whitespace_control
            skip(RE_TRIVIA)
            accept_tag(limit)
          end
        else
          # No more `%}`, but there could be `{{` and `}}`
          if scan_until(RE_MARKUP)
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

    #: (Integer) -> void
    def accept_tag(limit)
      tag_name = scan(RE_TAG_NAME)

      emit(:token_tag_name) unless tag_name.nil?

      case tag_name
      when "#"
        accept_inline_comment(limit)
      when "comment"
        accept_block_comment(limit)
      when "doc"
        accept_doc_comment(limit)
      when "raw"
        accept_raw_tag(limit)
      when "liquid"
        accept_line_statements(limit)
      else
        accept_expression(limit)
        skip(RE_TRIVIA)
        accept_whitespace_control
        scan(RE_TAG_END)
        emit(:token_tag_end)
      end
    end

    #: (Integer, ?Regexp) -> void
    def accept_expression(limit, trivia = RE_TRIVIA)
      loop do
        skip(trivia)

        # Trivia can put us past the limit
        break if @scanner.pos >= limit

        # We assume punctuation does not include markup delimiter characters,
        # and can therefore not exceed `limit`.
        if (match = scan(RE_PUNCTUATION))
          emit(TOKEN_MAP[match] || :token_unknown)
          next
        end

        # We assume identifiers do not allow markup delimiter characters,
        # and can therefore not exceed `limit`.
        if (match = scan(RE_IDENT))
          emit(TOKEN_MAP[match] || :token_ident)
          next
        end

        # RE_FLOAT must come before RE_INT
        if scan(RE_FLOAT)
          emit(:token_float)
          next
        end

        if scan(RE_INT)
          emit(:token_int)
          next
        end

        next_byte = @scanner.peek_byte # steep:ignore

        if next_byte == 39 || next_byte == 34
          accept_string_literal(limit)
        else
          @scanner.pos += 1
          emit(:token_unknown)
        end
      end
    end

    #: (Integer) -> void
    def accept_inline_comment(limit)
      @scanner.pos = limit
      emit(:token_comment)
      accept_whitespace_control
      scan(RE_TAG_END)
      emit(:token_tag_end)
    end

    #: (Integer) -> void
    def accept_block_comment(limit)
      skip(RE_TRIVIA)
      # Ignore any "expression".
      @scanner.pos = limit
      accept_whitespace_control
      scan(RE_TAG_END)
      emit(:token_tag_end)

      comment_depth = 1
      raw_depth = 0

      loop do
        match = skip_until(RE_COMMENT_SEGMENT)

        unless match
          emit(:token_unknown)
          break
        end

        case @scanner[1]
        when "comment"
          comment_depth += 1
          @scanner.pos += @scanner.matched_size || raise
        when "raw"
          raw_depth += 1
          @scanner.pos += @scanner.matched_size || raise
        when "endraw"
          raw_depth -= 1 if raw_depth.positive?
          @scanner.pos += @scanner.matched_size || raise
        when "endcomment"
          if raw_depth.positive?
            @scanner.pos += @scanner.matched_size || raise
            next
          end

          comment_depth -= 1

          if comment_depth.positive?
            @scanner.pos += @scanner.matched_size || raise
            next
          end

          emit(:token_comment)
          break
        else
          raise "unreachable"
        end
      end
    end

    #: (Integer) -> void
    def accept_doc_comment(limit)
      # Let the parser handle unexpected expression tokens.
      accept_expression(limit)
      skip(RE_TRIVIA)
      accept_whitespace_control
      scan(RE_TAG_END)
      emit(:token_tag_end)
      emit(:token_comment) if scan_until(RE_END_DOC)
    end

    #: (Integer) -> void
    def accept_raw_tag(limit)
      # Let the parser handle unexpected expression tokens.
      accept_expression(limit)
      skip(RE_TRIVIA)
      accept_whitespace_control
      scan(RE_TAG_END)
      emit(:token_tag_end)
      emit(:token_text) if scan_until(RE_END_RAW)
    end

    #: (Integer) -> void
    def accept_line_statements(limit)
      while @scanner.pos < limit
        skip(RE_TRIVIA)
        line_limit = index(RE_NEWLINE) || limit
        line_limit = limit if line_limit > limit

        emit(:token_tag_start)

        case scan(RE_TAG_NAME)
        when "#"
          emit(:token_tag_name)
          @scanner.pos = line_limit
          emit(:token_comment)
          emit(:token_tag_end)
        when "comment"
          emit(:token_tag_name)
          emit(:token_tag_end)
          accept_line_block_comment(limit)
        when "doc"
          emit(:token_tag_name)
          accept_line_doc_comment(limit)
        when "raw"
          emit(:token_tag_name)
          accept_line_raw_tag(limit)
        when "liquid"
          emit(:token_tag_name)
          accept_line_statements(line_limit)
        when nil
          # Remove empty :token_tag_start
          @tokens.pop
        else
          emit(:token_tag_name)
          accept_expression(line_limit, RE_LINE_TRIVIA)
          emit(:token_tag_end)
        end
      end

      skip(RE_TRIVIA)
      accept_whitespace_control
      scan(RE_TAG_END)
      emit(:token_tag_end)
    end

    #: (Integer) -> void
    def accept_line_block_comment(limit)
      comment_depth = 1

      while @scanner.pos < limit
        index_ = index(RE_LINE_COMMENT_SEGMENT)

        if index_.nil? || index_ >= limit
          emit(:token_unknown)
          break
        end

        unless skip_until(RE_LINE_COMMENT_SEGMENT)
          emit(:token_unknown)
          break
        end

        case @scanner[1]
        when "comment"
          comment_depth += 1
          @scanner.pos += @scanner.matched_size || raise
        when "endcomment"
          comment_depth -= 1
          if comment_depth.positive?
            @scanner.pos += @scanner.matched_size || raise
            next
          else
            emit(:token_comment)
            break
          end
        else
          raise "unreachable"
        end
      end
    end

    #: (Integer) -> void
    def accept_line_doc_comment(limit)
      # Shopify/liquid always raises a syntax error for `doc` in `{% liquid %}`.
      @scanner.pos = limit
      emit(:token_unknown)
    end

    #: (Integer) -> void
    def accept_line_raw_tag(limit)
      # Shopify/liquid always raises a syntax error for `raw` in `{% liquid %}`.
      @scanner.pos = limit
      emit(:token_unknown)
    end

    #: (Integer) -> void
    def accept_string_literal(limit)
      quote = @scanner.get_byte || raise
      double = quote == 34
      pattern = double ? RE_DOUBLE_QUOTE : RE_SINGLE_QUOTE
      kind = double ? :token_double_quote : :token_single_quote #: t_token_kind
      emit(kind)

      if @scanner.peek_byte == quote # steep:ignore
        # Empty string
        @scanner.pos += 1
        emit(kind)
        return
      end

      # Jump to the next quote or limit, whichever is closer.
      index_ = index(pattern) || limit
      index_ = limit if index_ > limit
      @scanner.pos = index_
      emit(kind)

      if @scanner.peek_byte == quote # steep:ignore
        @scanner.pos += 1
        emit(kind)
      end
    end

    #: () -> bool
    def accept_whitespace_control
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
