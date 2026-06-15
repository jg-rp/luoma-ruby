# frozen_string_literal: true

module Luoma
  # Liquid filters and helper methods.
  module Filters
    # Return the size of _left_, or zero if _left_ has no size.
    def self.size(context, left)
      left.respond_to?(:size) ? left.size : 0
    end
  end
end
