# frozen_string_literal: true

require "strscan"

module Luoma
  # The base class for template source code tokenizers.
  class BaseLexer
    attr_reader :tokens

    #: (Environment, String) -> Array[t_token]
    def self.tokenize(env, source)
      lexer = new(env, source)
      lexer.go
      lexer.tokens
    end

    #: (Environment, String) -> void
    def initialize(env, source)
      @env = env
      @source = source
      @scanner = StringScanner.new(source)
      @start = 0
      @tokens = [] #: Array[t_token]
    end

    #: () -> void
    def go
      state = :scan_markup
      state = send(state) until state.nil?
    end

    protected

    # Scanner entry point. If a symbol is returned it should match the name of
    # a method implementing the next state. A return value of `nil` means we
    # should stop scanning.
    #: () -> Symbol?
    def scan_markup
      raise "not implemented"
    end

    # Emit a token of `kind` spanning @start to @scanner.pos.
    #: (t_token_kind) -> void
    def emit(kind)
      @tokens << { kind: kind, start: @start, stop: @scanner.pos - 1 }
      @start = @scanner.pos
    end

    # Return the index of the next match of `pattern` without
    # advancing the scanner.
    #: (Regexp) -> Integer?
    def index(pattern)
      byte_offset = @scanner.exist?(pattern)
      return nil unless byte_offset

      @scanner.pos + byte_offset - (@scanner.matched_size || raise)
    end

    #: (Regexp) -> String?
    def scan(pattern)
      @scanner.scan(pattern)
    end

    # Scan up to but not including `pattern`.
    #: (Regexp) -> bool
    def scan_until(pattern)
      byte_offset = @scanner.exist?(pattern)
      if byte_offset.nil?
        false
      else
        @scanner.pos += byte_offset - (@scanner.matched_size || raise)
        true
      end
    end

    #: (Regexp) -> bool
    def skip(pattern)
      if @scanner.scan(pattern)
        @start = @scanner.pos
        true
      else
        false
      end
    end

    # Skip up to but not including `pattern`.
    #: (Regexp) -> bool
    def skip_until(pattern)
      byte_offset = @scanner.exist?(pattern)
      if byte_offset.nil?
        false
      else
        @scanner.pos += byte_offset - (@scanner.matched_size || raise)
        @start = @scanner.pos
        true
      end
    end
  end
end
