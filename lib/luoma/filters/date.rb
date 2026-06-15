# frozen_string_literal: true

module Luoma
  # Liquid filters and helper methods.
  module Filters
    # Format date and time object _left_ with _format_.
    # Coerce _left_ to a `Time` if it is not a time-like object already.
    # Coerce _format_ to a string if it is not a string already.
    def self.date(context, left, format)
      format = context.to_string(format)
      return left if format.empty?

      if (date = context.to_date(left))
        date.strftime(format)
      else
        left
      end
    end
  end
end
