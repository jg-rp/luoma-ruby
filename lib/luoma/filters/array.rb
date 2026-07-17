# frozen_string_literal: true

module Luoma
  module Filters
    # Return the concatenation of items in _left_ separated by _sep_.
    # Coerce items in _left_ to strings if they aren't strings already.
    def self.join(context, left, sep = " ")
      context.to_enumerable(left).map { |item| context.to_string(item) }.join(context.to_string(sep))
    end

    # If _left_ is enumerable, return _left_ flattened to _depth_. Otherwise
    # return _left_.
    def self.flatten(context, left, depth = nil)
      left = context.to_enumerable(left)

      context.to_a(left).flatten(
        depth.nil? ? depth : context.to_numeric(depth, default: 1).to_i # steep:ignore
      )
    end

    # Return true if at least one item in _left_ is truthy.
    def self.any(context, left, key = :nothing, value = :nothing)
      left = context.to_enumerable(left)

      case key
      when :nothing
        left.any? { |i| context.truthy?(i) }
      when ExpressionDrop
        key.expr.broadcast_with_index(left).any? { |i| context.truthy?(i) }
      else
        key = context.to_string(key)
        if value == :nothing
          left.map { |i| context.fetch(i, key) }.any? { |j| context.truthy?(j) }
        else
          left.map { |i| context.fetch(i, key) }.any? { |j| context.eq?(j, value) }
        end
      end
    end

    # Return true if all items in _left_ are truthy.
    def self.all(context, left, key = :nothing, value = :nothing)
      left = context.to_enumerable(left)

      case key
      when :nothing
        left.all? { |i| context.truthy?(i) }
      when ExpressionDrop
        key.expr.broadcast_with_index(left).all? { |i| context.truthy?(i) }
      else
        key = context.to_string(key)
        if value == :nothing
          left.map { |i| context.fetch(i, key) }.all? { |j| context.truthy?(j) }
        else
          left.map { |i| context.fetch(i, key) }.all? { |j| context.eq?(j, value) }
        end
      end
    end

    # Return a copy of _left_ with nil items removed.
    # Coerce _left_ to an array-like object if it is not one already.
    #
    # If _key_ is given, assume items in _left_ are hash-like and remove items from _left_
    # where `item.fetch(key, nil)` is nil.
    #
    # If key is not `:nothing`, coerce it to a string before calling `fetch` on items in
    # _left_.
    def self.compact(context, left, key = :nothing)
      left = context.to_enumerable(left)

      case key
      when :nothing
        left.compact
      when ExpressionDrop
        left.each_with_index.reject do |item, index|
          value = key.expr.call_with_index(item, index)
          value.nil? || context.nothing?(value)
        end.map(&:first)
      else
        left.reject do |item|
          value = context.fetch(item, key)
          value.nil? || context.nothing?(value)
        end
      end
    end

    # Return _left_ concatenated with _right_.
    # Coerce _left_ and _right_ to an array if they aren't arrays already.
    def self.concat(context, left, right)
      context.to_a(left).concat(context.to_a(right))
    end

    # Return the first item in _left_ where _key_ is equal to _value_, or nil
    # if no such item exists.
    #
    # If _value_ is not given, return the first item where _key_ is truthy.
    #
    # If _key_ is a Lambda expression, evaluate the expression for each item in
    # _left_ and return the first item where the expression results in a truthy
    # value, ignoring _value_.
    def self.find(context, left, key, value = :nothing)
      left = context.to_enumerable(left)

      if key.is_a?(ExpressionDrop)
        key.expr.broadcast_with_index(left).zip(left) do |r, i|
          return i if context.truthy?(r)
        end
      elsif value == :nothing
        key_ = context.to_string(key)
        left.each do |item|
          return item if context.truthy?(context.fetch(item, key_)) || context.eq?(item, key)
        end
      else
        key = context.to_string(key)
        left.each do |item|
          return item if context.eq?(context.fetch(item, key), value) || context.eq?(item, value)
        end
      end

      nil
    end

    # Return the index of the first item in _left_ where _key_ is equal to
    # _value_, or nil if no such item exists.
    #
    # If _value_ is not given, return the index of the first item where _key_
    # is truthy.
    #
    # If _key_ is a Lambda expression, evaluate the expression for each item in
    # _left_ and return the index of the  first item where the expression
    # results in a truthy value, ignoring _value_.
    def self.find_index(context, left, key, value = :nothing)
      left = context.to_enumerable(left)

      if key.is_a?(ExpressionDrop)
        key.expr.broadcast_with_index(left).each_with_index do |item, index|
          return index if context.truthy?(item)
        end
      elsif value == :nothing
        key_ = context.to_string(key)
        left.each_with_index do |item, index|
          return index if context.truthy?(context.fetch(item, key_)) || context.eq?(item, key)
        end
      else
        key = context.to_string(key)
        left.each_with_index do |item, index|
          return index if context.eq?(context.fetch(item, key), value) || context.eq?(item, value)
        end
      end

      nil
    end

    # Return the first item in _left_, or `:nothing` if _left_ does not have a
    # first item.
    #
    # Coerce _left_ to an array if it is not a string, hash or array.
    def self.first(context, left)
      case left
      when String
        left.empty? ? :nothing : left[0]
      when Hash, Array
        left.empty? ? :nothing : left.first
      else
        left_ = context.to_a(left)
        left_.empty? ? :nothing : left_.first
      end
    end

    # Return the last item in _left_, or `:nothing` if _left_ does not have a
    # last item.
    #
    # Coerce _left_ to an array if it is not a string or array.
    def self.last(context, left)
      case left
      when String
        left.empty? ? :nothing : left[-1]
      when Array
        left.empty? ? :nothing : left.last
      else
        left_ = context.to_a(left)
        left_.empty? ? :nothing : left_.last
      end
    end

    def self.map(context, left, key)
      left = context.to_enumerable(left)

      if key.is_a?(ExpressionDrop)
        key.expr.broadcast_with_index(left)
      else
        key = context.to_string(key)
        left.map { |item| context.fetch(item, key) }
      end
    end

    # Return _left_ with all items in reverse order.
    # Coerce _left_ to an array if it isn't an array already.
    def self.reverse(context, left)
      context.to_a(left).reverse
    end

    def self.reject(context, left, key, value = :nothing)
      left = context.to_enumerable(left)

      if key.is_a?(ExpressionDrop)
        left.each_with_index.reject do |item, index|
          context.truthy?(key.expr.call_with_index(item, index))
        end.map(&:first)
      elsif value == :nothing
        key_ = context.to_string(key)
        left.reject do |item|
          context.truthy?(context.fetch(item, key_)) || context.eq?(item, key)
        end
      else
        key = context.to_string(key)
        left.reject do |item|
          context.eq?(context.fetch(item, key), value) || context.eq?(item, value)
        end
      end
    end

    def self.where(context, left, key, value = :nothing)
      left = context.to_enumerable(left)

      if key.is_a?(ExpressionDrop)
        left.each_with_index.filter do |item, index|
          context.truthy?(key.expr.call_with_index(item, index))
        end.map(&:first)
      elsif value == :nothing
        key_ = context.to_string(key)
        left.filter do |item|
          context.truthy?(context.fetch(item, key_)) || context.eq?(item, key)
        end
      else
        key = context.to_string(key)
        left.filter do |item|
          context.eq?(context.fetch(item, key), value) || context.eq?(item, value)
        end
      end
    end

    # Deduplicate items in _left_.
    # Coerce _left_ to an array if it isn't an array already.
    def self.uniq(context, left, key = :nothing)
      left = context.to_a(left)

      # Like Array#uniq but using our own comparator, context#eq?.
      # @type var uniq_: ^(Array[untyped]) ?{ (untyped, Integer) -> untyped } -> Array[untyped]
      uniq_ = lambda do |array, &key|
        decorated = [] #: Array[untyped]
        result = [] #: Array[untyped]

        array.each_with_index do |item, index|
          value = key ? key.call(item, index) : item

          unless decorated.any? { |existing| context.eq?(existing, value) }
            decorated << value
            result << item
          end
        end

        result
      end

      if key == :nothing
        uniq_.call(left)
      elsif key.is_a?(ExpressionDrop)
        uniq_.call(left) { |item, index| key.expr.call_with_index(item, index) }
      else
        key = context.to_string(key)
        uniq_.call(left) { |item, _index| context.fetch(item, key) }
      end
    end

    # Return the sum of all numeric values in the input array.
    def self.sum(context, left, key = :nothing)
      left = context.to_enumerable(left)

      if key == :nothing
        left.sum { |v| context.to_numeric(v, default: 0) }
      elsif key.is_a?(ExpressionDrop)
        key.expr.broadcast_with_index(left).sum { |v| context.to_numeric(v, default: 0) }
      else
        key = context.to_string(key)
        left.sum { |v| context.to_numeric(context.fetch(v, key, default: 0)) }
      end
    end

    # Combine _left_ with _right_, producing an array or pairs.
    # Coerce _left_ and _right_ to arrays if they aren't arrays already.
    def self.zip(context, left, right)
      context.to_a(left).zip(context.to_a(right))
    end

    # Return the minimum numeric value found in _left_.
    # Coerce _left_ to an array if it's not an array already.
    def self.min(context, left, key = :nothing)
      left = context.to_enumerable(left)

      # @type var min_: ^(Enumerable[untyped]) ?{ (untyped, Integer) -> untyped } -> untyped
      min_ = lambda do |enum, &key|
        best_item = nil #:untyped
        best_value = nil #: Numeric?

        enum.each_with_index do |item, index|
          value = context.to_numeric(key ? key.call(item, index) : item, default: nil)
          next if value.nil?

          if best_value.nil? || context.lt?(value, best_value)
            best_item = item
            best_value = value
          end
        end

        best_item
      end

      if key == :nothing
        min_.call(left)
      elsif key.is_a?(ExpressionDrop)
        min_.call(left) { |item, index| key.expr.call_with_index(item, index) }
      else
        key = context.to_string(key)
        min_.call(left) { |item, _index| context.fetch(item, key, default: nil) }
      end
    end

    # Return the maximum numeric value found in _left_.
    # Coerce _left_ to an array if it's not an array already.
    def self.max(context, left, key = :nothing)
      left = context.to_enumerable(left)

      # @type var max_: ^(Enumerable[untyped]) ?{ (Integer, untyped) -> untyped } -> untyped
      max_ = lambda do |enum, &key|
        best_item = nil # untyped
        best_value = nil #: Numeric?

        enum.each_with_index do |item, index|
          value = context.to_numeric(key ? key.call(item, index) : item, default: nil)
          next if value.nil?

          if best_value.nil? || context.lt?(best_value, value)
            best_item = item
            best_value = value
          end
        end

        best_item
      end

      if key == :nothing
        max_.call(left)
      elsif key.is_a?(ExpressionDrop)
        max_.call(left) { |item, index| key.expr.call_with_index(item, index) }
      else
        key = context.to_string(key)
        max_.call(left) { |item, _index| context.fetch(item, key, default: nil) }
      end
    end
  end
end
