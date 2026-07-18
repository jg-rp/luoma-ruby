# frozen_string_literal: true

module Luoma
  module Filters
    # Return the absolute value of `left`.
    def self.abs(context, left)
      left_ = context.to_numeric(left)
      context.nothing?(left_) ? left_ : left_.abs
    end

    # Return the maximum of `left` and `right`.
    def self.at_least(context, left, right)
      [context.to_numeric(left, default: nil), context.to_numeric(right, default: nil)].compact.max
    end

    # Return the minimum of `left` and `right`.
    def self.at_most(context, left, right)
      [context.to_numeric(left, default: nil), context.to_numeric(right, default: nil)].compact.min
    end

    # Return `left` rounded up to the next whole number.
    def self.ceil(context, left)
      left_ = context.to_numeric(left)
      context.nothing?(left_) ? left_ : left_.ceil
    end

    # Return the result of dividing `left` by `right`.
    # If both `left` and `right` are integers, integer division is performed.
    def self.divided_by(context, left, right)
      lhs = context.to_numeric(left, default: :nothing)
      rhs = context.to_numeric(right, default: :nothing)
      return :nothing if context.nothing?(lhs) || context.nothing?(rhs) || rhs.zero? # steep:ignore

      result = lhs.to_d / rhs # steep:ignore
      result.frac.zero? && lhs.is_a?(::Integer) && rhs.is_a?(::Integer) ? result.to_i : result
    end

    # Return the result of multiplying `left` by `right`.
    def self.times(context, left, right)
      lhs = context.to_numeric(left, default: :nothing)
      rhs = context.to_numeric(right, default: :nothing)
      context.nothing?(lhs) || context.nothing?(rhs) ? :nothing : lhs * rhs # steep:ignore
    end

    # Return `left` rounded down to the next whole number.
    def self.floor(context, left)
      left_ = context.to_numeric(left)
      context.nothing?(left_) ? left_ : left_.floor
    end

    # Return `right` subtracted from `left`.
    def self.minus(context, left, right)
      lhs = context.to_numeric(left, default: :nothing)
      rhs = context.to_numeric(right, default: :nothing)
      context.nothing?(lhs) || context.nothing?(rhs) ? :nothing : lhs - rhs # steep:ignore
    end

    # Return the remainder of dividing `left` by `right`.
    def self.modulo(context, left, right)
      lhs = context.to_numeric(left, default: :nothing)
      rhs = context.to_numeric(right, default: :nothing)
      return :nothing if context.nothing?(lhs) || context.nothing?(rhs) || rhs.zero? # steep:ignore

      result = lhs.to_d % rhs # steep:ignore
      result.frac.zero? && lhs.is_a?(::Integer) && rhs.is_a?(::Integer) ? result.to_i : result
    end

    # Return `right` added to `left`.
    def self.plus(context, left, right)
      lhs = context.to_numeric(left, default: :nothing)
      rhs = context.to_numeric(right, default: :nothing)
      context.nothing?(lhs) || context.nothing?(rhs) ? :nothing : lhs + rhs # steep:ignore
    end

    # Return `left` rounded to _ndigits_ decimal digits.
    def self.round(context, left, ndigits = 0)
      left_ = context.to_numeric(left)
      return left_ if context.nothing?(left_)
      return left.round_ if ndigits == 0 # rubocop:disable Style/NumericPredicate

      left_.round(context.to_i(ndigits, default: 0))
    end
  end
end
