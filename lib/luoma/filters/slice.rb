# frozen_string_literal: true

module Luoma
  module Filters
    def self.slice(
      context,
      left,
      start_ = :nothing, stop_ = :nothing, step_ = :nothing,
      start: :nothing, stop: :nothing, step: :nothing
    )
      left = context.to_a(left) unless left.is_a?(String)

      # Give priority to keyword arguments, default to nil if neither are given.
      start = start_ == :nothing ? nil : start_ if start == :nothing
      stop = stop_ == :nothing ? nil : stop_ if stop == :nothing
      step = step_ == :nothing ? nil : step_ if step == :nothing

      step = context.to_i(step || 1, default: 0)
      length = left.length
      return [] if length.zero? || step.zero?

      start = context.to_i(start, default: 0) unless start.nil?
      stop = context.to_i(stop, default: 0) unless stop.nil?

      normalized_start = if start.nil?
                           step.negative? ? length - 1 : 0
                         elsif start&.negative?
                           [length + start, 0].max
                         else
                           [start, length - 1].min
                         end

      normalized_stop = if stop.nil?
                          step.negative? ? -1 : length
                        elsif stop&.negative?
                          [length + stop, -1].max
                        else
                          [stop, length].min
                        end

      # This does not work for strings.
      # left[(normalized_start...normalized_stop).step(step)]
      #
      # But this does.
      (normalized_start...normalized_stop).step(step).map { |i| left[i] }
    end
  end
end
