# frozen_string_literal: true

module Luoma
  # Combine multiple hashes for sequential lookup.
  class ChainHash
    #: (*_Namespace) -> void
    def initialize(*hashes)
      @hashes = hashes.to_a
    end

    #: (String) -> untyped
    def [](key)
      index = @hashes.length - 1
      while index >= 0
        h = @hashes[index]
        index -= 1
        return h[key] if h.key?(key)
      end
    end

    #: (String) -> bool
    def key?(key)
      !@hashes.rindex { |h| h.key?(key) }.nil?
    end

    #: (String, untyped) -> untyped
    def fetch(key, default = :nothing)
      index = @hashes.length - 1
      while index >= 0
        h = @hashes[index]
        index -= 1
        return h[key] if h.key?(key)
      end

      default
    end

    def size = @hashes.length
    def push(hash) = @hashes << hash
    alias << push
    def pop = @hashes.pop
  end
end
