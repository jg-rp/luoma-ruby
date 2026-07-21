# frozen_string_literal: true

module Luoma
  module Filters
    INFINITY_ARRAY = [Float::INFINITY].freeze # : [Float]

    # Return a sorted array of items in _left_. If _left_ contains incomparable
    # items, return _left_ as an array with its original ordering.
    #
    # Coerce _left_ to an array if it's not one already.
    def self.sort(context, left, key = :nil)
      left = context.to_a(left)

      # @type var sort_: ^(Array[untyped]) ?{ (untyped, Integer) -> untyped } -> Array[untyped]
      sort_ = lambda do |array, &key|
        # TODO: nil safe key?
        decorated = array.each_with_index.map do |item, index|
          [item, key ? key.call(item, index) : item]
        end

        begin
          decorated.sort! do |(_, a), (_, b)|
            cmp = context.cmp?(a, b)
            raise IncomparableValues if cmp.nil?

            cmp
          end
        rescue IncomparableValues
          raise LuomaError.new("Cannot sort incomparable values") if context.render_context.env.strict_filters

          return array
        end

        decorated.map!(&:first)
      end

      if key.nil?
        sort_.call(left)
      elsif key.is_a?(ExpressionDrop)
        sort_.call(left) { |item, index| key.expr.call_with_index(item, index) }
      else
        key = context.to_string(key)
        sort_.call(left) { |item, _index| context.fetch(item, key) }
      end
    end

    def self.sort_natural(context, left, key = :nothing)
      left = context.to_enumerable(left)

      if context.nothing?(key)
        left.sort { |a, b| nil_safe_casecmp(a, b) }
      else
        key = context.to_string(key)
        left.sort { |a, b| nil_safe_casecmp(context.fetch(a, key), context.fetch(b, key)) }
      end
    end

    def self.sort_numeric(context, left, key = :nothing)
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
        0
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
