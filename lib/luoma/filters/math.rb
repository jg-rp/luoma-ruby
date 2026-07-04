# frozen_string_literal: true

module Luoma
  module Filters
    # Return the absolute value of `left`.
    def self.abs(context, left)
      context.to_numeric(left).abs
    end

    # Return the maximum of `left` and `right`.
    def self.at_least(context, left, right)
      [context.to_numeric(left), context.to_numeric(right)].max
    end

    # Return the minimum of `left` and `right`.
    def self.at_most(context, left, right)
      [context.to_numeric(left), context.to_numeric(right)].min
    end

    # Return `left` rounded up to the next whole number.
    def self.ceil(context, left)
      context.to_numeric(left).ceil
    end

    # Return the result of dividing `left` by `right`.
    # If both `left` and `right` are integers, integer division is performed.
    def self.divided_by(context, left, right)
      context.to_numeric(left) / context.to_numeric(right)
    rescue ZeroDivisionError => e
      raise context.type_error(e.message)
    end

    # Return the result of multiplying `left` by `right`.
    def self.times(context, left, right)
      context.to_numeric(left) * context.to_numeric(right)
    end

    # Return `left` rounded down to the next whole number.
    def self.floor(context, left)
      context.to_numeric(left).floor
    end

    # Return `right` subtracted from `left`.
    def self.minus(context, left, right)
      context.to_numeric(left) - context.to_numeric(right)
    end

    # Return the remainder of dividing `left` by `right`.
    def self.modulo(context, left, right)
      context.to_numeric(left) % context.to_numeric(right)
    rescue ZeroDivisionError => e
      raise context.type_error(e.message)
    end

    # Return `right` added to `left`.
    def self.plus(context, left, right)
      left_ = context.to_numeric(left, default: :nothing)
      right_ = context.to_numeric(right, default: :nothing)
      left_ == :nothing || right_ == :nothing ? :nothing : left_ + right_ # steep:ignore
    end

    # Return `left` rounded to _ndigits_ decimal digits.
    def self.round(context, left, ndigits = 0)
      left = context.to_numeric(left)
      return left.round if ndigits == 0 # rubocop:disable Style/NumericPredicate

      left.round(context.to_i(ndigits))
    end
  end
end
