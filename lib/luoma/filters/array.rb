# frozen_string_literal: true

module Luoma
  module Filters
    # Return the concatenation of items in _left_ separated by _sep_.
    # Coerce items in _left_ to strings if they aren't strings already.
    def self.join(left, sep = " ", context:)
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
    def self.compact(left, key = :nothing, context:)
      left = context.to_enumerable(left)

      case key
      when :nothing
        left.compact
      else
        left.reject do |item|
          item.respond_to?(:fetch) ? item.fetch(key, nil).nil? : true
        end
      end
    end

    # Return _left_ concatenated with _right_, or nil if _right_ is not an array.
    # Coerce _left_ to an array if it isn't an array already.
    def self.concat(left, right, context:)
      raise context.argument_error("expected an array") unless right.respond_to?(:to_ary)

      context.to_enumerable(left).to_a.concat(right)
    end

    def self.find(left, key, value = nil, context:)
      left = context.to_enumerable(left)

      if !context.nothing?(value)
        left.each do |item|
          return item if context.fetch(item, key) == value
        end
      else
        left.each do |item|
          return item if context.fetch(item, key)
        end
      end

      nil
    end

    def self.find_index(left, key, value = nil, context:)
      left = context.to_enumerable(left)

      if !context.nothing?(value)
        left.each_with_index do |item, index|
          return index if context.fetch(item, key) == value
        end
      else
        left.each_with_index do |item, index|
          return index if context.fetch(item, key)
        end
      end

      nil
    end

    def self.has(left, key, value = nil, context:)
      left = context.to_enumerable(left)

      if !context.nothing?(value)
        left.each do |item|
          return true if context.fetch(item, key) == value
        end
      else
        left.each do |item|
          return true if context.fetch(item, key)
        end
      end

      false
    end

    # Return the first item in _left_, or `nil` if _left_ does not have a first item.
    def self.first(left)
      case left
      when String
        left[0]
      else
        left.first if left.respond_to?(:first)
      end
    end

    # Return the last item in _left_, or `nil` if _left_ does not have a last item.
    def self.last(left)
      case left
      when String
        left[-1]
      else
        left.last if left.respond_to?(:last)
      end
    end

    def self.map(left, key, context:)
      left = context.to_enumerable(left)
      key = context.to_string(key)
      left.map { |item| item[key] }
    end

    # Return _left_ with all items in reverse order.
    # Coerce _left_ to an array if it isn't an array already.
    def self.reverse(left, context:)
      context.to_enumerable(left).to_a.reverse
    end

    def self.reject(left, key, value = nil, context:)
      left = context.to_enumerable(left)
      key = context.to_string(key)

      if !context.nothing?(value)
        left.reject do |item|
          context.fetch(item, key) == value
        end
      else
        left.reject do |item|
          context.truthy?(context.fetch(item, key))
        end
      end
    end

    def self.where(left, key, value = nil, context:)
      left = context.to_enumerable(left)
      key = context.to_string(key)

      if !context.nothing?(value)
        left.filter do |item|
          context.fetch(item, key) == value
        end
      else
        left.filter do |item|
          context.truthy?(context.fetch(item, key))
        end
      end
    end

    # Deduplicate items in _left_.
    # Coerce _left_ to an array if it isn't an array already.
    def self.uniq(left, key = nil, context:)
      left = context.to_enumerable(left)

      if context.nothing?(key)
        left.to_a.uniq
      else
        left.to_a.uniq { |item| context.fetch(item, key) }
      end
    end

    # TODO: sum
  end
end
