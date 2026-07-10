# frozen_string_literal: true

module Luoma
  module Filters
    # Return the concatenation of items in _left_ separated by _sep_.
    # Coerce items in _left_ to strings if they aren't strings already.
    def self.join(context, left, sep = " ")
      context.to_enumerable(left).map { |item| context.to_string(item) }.join(context.to_string(sep))
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
          # TODO: convenience for nothing or nil
          value.nil? || context.nothing?(value)
        end.map(&:first)
      else
        # TODO: reject nothing or nil
        left.reject do |item|
          item.respond_to?(:fetch) ? item.fetch(key, nil).nil? : true
        end
      end
    end

    # Return _left_ concatenated with _right_, or nil if _right_ is not an array.
    # Coerce _left_ to an array if it isn't an array already.
    def self.concat(context, left, right)
      raise context.argument_error("expected an array") unless right.respond_to?(:to_ary)

      context.to_enumerable(left).to_a.concat(right)
    end

    def self.find(context, left, key, value = nil)
      left = context.to_enumerable(left)

      if key.is_a?(ExpressionDrop)
        key.expr.broadcast_with_index(left).zip(left) do |r, i|
          return i if context.truthy?(r)
        end
      elsif context.nothing?(value)
        left.each do |item|
          return item if context.fetch(item, key)
        end
      else
        left.each do |item|
          return item if context.fetch(item, key) == value
        end
      end

      nil
    end

    def self.find_index(context, left, key, value = nil)
      left = context.to_enumerable(left)

      # TODO: ExpressionDrop

      if context.nothing?(value)
        left.each_with_index do |item, index|
          return index if context.fetch(item, key)
        end
      else
        left.each_with_index do |item, index|
          return index if context.fetch(item, key) == value
        end
      end

      nil
    end

    def self.has(context, left, key, value = nil) # rubocop:disable Naming/PredicateMethod
      left = context.to_enumerable(left)

      # TODO: ExpressionDrop

      if context.nothing?(value)
        left.each do |item|
          return true if context.fetch(item, key)
        end
      else
        left.each do |item|
          return true if context.fetch(item, key) == value
        end
      end

      false
    end

    # Return the first item in _left_, or `nil` if _left_ does not have a first item.
    def self.first(context, left)
      # TODO: default to :nothing?
      case left
      when String
        left[0]
      else
        left.first if left.respond_to?(:first)
      end
    end

    # Return the last item in _left_, or `nil` if _left_ does not have a last item.
    def self.last(context, left)
      # TODO: default to :nothing?
      case left
      when String
        left[-1]
      else
        left.last if left.respond_to?(:last)
      end
    end

    def self.map(context, left, key)
      left = context.to_enumerable(left)

      if key.is_a?(ExpressionDrop)
        key.expr.broadcast_with_index(left)
      else
        key = context.to_string(key)
        left.map { |item| item[key] }
      end
    end

    # Return _left_ with all items in reverse order.
    # Coerce _left_ to an array if it isn't an array already.
    def self.reverse(context, left)
      context.to_a(left).reverse
    end

    def self.reject(context, left, key, value = nil)
      left = context.to_enumerable(left)
      key = context.to_string(key)

      # TODO: ExpressionDrop

      if context.nothing?(value)
        left.reject do |item|
          context.truthy?(context.fetch(item, key))
        end
      else
        left.reject do |item|
          context.fetch(item, key) == value
        end
      end
    end

    def self.where(context, left, key, value = nil)
      left = context.to_enumerable(left)
      key = context.to_string(key)

      # TODO: ExpressionDrop

      if context.nothing?(value)
        left.filter do |item|
          context.truthy?(context.fetch(item, key))
        end
      else
        left.filter do |item|
          context.fetch(item, key) == value
        end
      end
    end

    # Deduplicate items in _left_.
    # Coerce _left_ to an array if it isn't an array already.
    def self.uniq(context, left, key = nil)
      left = context.to_enumerable(left)

      # TODO: ExpressionDrop

      if context.nothing?(key)
        left.to_a.uniq
      else
        left.to_a.uniq { |item| context.fetch(item, key) }
      end
    end

    # Return the sum of all numeric values in the input array.
    def self.sum(context, left, key = nil)
      left = context.to_enumerable(left)

      # TODO: ExpressionDrop

      if context.nothing?(key)
        left.sum { |v| context.to_numeric(v) }
      else
        left.sum { |v| context.to_numeric(context.fetch(v, key)) }
      end
    end
  end
end
