# frozen_string_literal: true

module Luoma
  module Filters
    # Return the absolute value of `left`.
    def self.abs(left, context:)
      context.to_numeric(left).abs
    end

    # Return the maximum of `left` and `right`.
    def self.at_least(left, right, context:)
      [context.to_numeric(left), context.to_numeric(right)].max
    end

    # Return the minimum of `left` and `right`.
    def self.at_most(left, right, context:)
      [context.to_numeric(left), context.to_numeric(right)].min
    end

    # Return `left` rounded up to the next whole number.
    def self.ceil(left, context:)
      context.to_numeric(left).ceil
    end

    # Return the result of dividing `left` by `right`.
    # If both `left` and `right` are integers, integer division is performed.
    def self.divided_by(left, right, context:)
      context.to_decimal(left) / context.to_decimal(right) # steep:ignore
    rescue ZeroDivisionError => e
      raise context.type_error(e.message)
    end

    # Return the result of multiplying `left` by `right`.
    def self.times(left, right, context:)
      context.to_decimal(left) * context.to_decimal(right) # steep:ignore
    end

    # Return `left` rounded down to the next whole number.
    def self.floor(left, context:)
      context.to_numeric(left).floor
    end

    # Return `right` subtracted from `left`.
    def self.minus(left, right, context:)
      context.to_decimal(left) - context.to_decimal(right)
    end

    # Return the remainder of dividing `left` by `right`.
    def self.modulo(left, right, context:)
      context.to_decimal(left) % context.to_decimal(right)
    rescue ZeroDivisionError => e
      raise context.type_error(e.message)
    end

    # Return `right` added to `left`.
    def self.plus(left, right, context:)
      context.to_decimal(left) + context.to_decimal(right)
    end

    # Return `left` rounded to _ndigits_ decimal digits.
    def self.round(left, ndigits = 0, context:)
      left = context.to_decimal(left)
      return left.round if ndigits == 0 # rubocop:disable Style/NumericPredicate

      left.round(context.to_i(ndigits))
    end
  end
end
