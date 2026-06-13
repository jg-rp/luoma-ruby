# frozen_string_literal: true

module Luoma
  module Filters
    # Return the absolute value of _left_.
    def self.abs(left)
      to_number(left).abs
    end
  end
end
