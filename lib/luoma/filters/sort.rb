# frozen_string_literal: true

module Luoma
  module Filters
    INFINITY_ARRAY = [Float::INFINITY].freeze # : [Float]

    def self.sort(context, left, key = nil)
      left = context.to_enumerable(left)

      if context.nothing?(key)
        left.sort { |a, b| nil_safe_compare(context, a, b) }
      else
        key = context.to_string(key)
        left.sort { |a, b| nil_safe_compare(context, context.fetch(a, key), context.fetch(b, key)) }
      end
    end

    def self.sort_natural(context, left, key = nil)
      left = context.to_enumerable(left)

      if context.nothing?(key)
        left.sort { |a, b| nil_safe_casecmp(a, b) }
      else
        key = context.to_string(key)
        left.sort { |a, b| nil_safe_casecmp(context.fetch(a, key), context.fetch(b, key)) }
      end
    end

    def self.sort_numeric(context, left, key = nil)
      left = context.to_enumerable(left)

      if context.nothing?(key)
        left.sort { |a, b| numeric_compare(a, b) }
      else
        key = context.to_string(key)
        left.sort { |a, b| numeric_compare(context.fetch(a, key), context.fetch(b, key)) }
      end
    end

    def self.nil_safe_compare(context, left, right)
      result = left <=> right

      if result
        result
      elsif left.nil?
        1
      elsif right.nil?
        -1
      else
        raise context.argument_error("can't sort incomparable type")
      end
    end

    def self.nil_safe_casecmp(left, right)
      if !left.nil? && !right.nil?
        left.to_s.casecmp(right.to_s)
      elsif left.nil? && right.nil?
        0
      else
        left.nil? ? 1 : -1
      end
    end

    def self.numeric_compare(left, right)
      # @type var res: untyped
      res = ints(left) <=> ints(right)
      res || -1
    end

    def self.ints(obj)
      if obj.is_a?(Integer) || obj.is_a?(Float) || obj.is_a?(BigDecimal)
        [obj]
      else
        numeric = obj.to_s.scan(/(?<=\.)0+|-?\d+/)
        return INFINITY_ARRAY if numeric.empty?

        numeric.map(&:to_i)
      end
    end
  end
end
