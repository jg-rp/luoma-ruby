# frozen_string_literal: true

module Luoma
  # Liquid filters and helper methods.
  module Filters
    # Return the subsequence of _left_ starting at _start_ up to _length_.
    def self.slice(context, left, start, length = 1)
      length = 1 if context.nothing?(length)

      if left.is_a?(Array)
        left.slice(context.to_integer(start), context.to_integer(length)) || []
      else
        context.to_string(left).slice(context.to_integer(start), context.to_integer(length)) || ""
      end
    end
  end
end
