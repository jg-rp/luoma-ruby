# frozen_string_literal: true

module Luoma
  def self.fnv1a32(s)
    hash = 0x811c9dc5 # offset basis for 32 bit hash

    s.bytes do |b|
      hash ^= b
      hash *= 0x01000193 # FNV prime for 32 bit hash
      hash &= (1 << 32) - 1
    end

    hash
  end
end
