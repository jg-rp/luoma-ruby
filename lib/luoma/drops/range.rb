# frozen_string_literal: true

module Luoma
  class RangeDrop < Drop
    attr_reader :start, :stop

    #: (Integer, Integer) -> void
    def initialize(start, stop)
      super()
      @start = start
      @stop = stop
      @range = start..stop
    end

    #: (untyped, RenderContext) -> bool
    def key?(obj, context)
      obj == "first" || obj == "last" || obj == "size"
    end

    #: (String, RenderContext) -> untyped
    def fetch(name, context, default: :nothing)
      case name
      when "first"
        @start
      when "last"
        @stop
      when "size"
        @range.size
      else
        default
      end
    end

    #: (untyped, RenderContext) -> bool
    def eq?(obj, context)
      obj.is_a?(RangeDrop) && obj.start == @start && obj.stop == @stop
    end

    def each
      @range
    end

    #: (RenderContext) -> Integer
    def length(context) # steep:ignore
      @range.size
    end

    #: (Integer?, Integer?, bool?) -> Enumerable[Integer]
    def slice(offset, limit, reversed)
      return self if offset.nil? && limit.nil?

      size = @stop - @start + 1
      start = offset&.negative? ? size + offset : offset || 0
      length = limit || size

      return RangeDrop.new(1, 0) if start.negative? || start >= size || length.negative?
      return RangeDrop.new(1, 0) if length.zero?

      stop = [start + length - 1, size - 1].min
      range = RangeDrop.new(@start + start, @start + stop)
      reversed ? range.to_a.reverse! : range
    end

    def to_primitive(hint, context)
      case hint
      when :data
        to_a
      when :string
        to_s
      when :boolean
        (@range.size || raise).positive?
      else
        :nothing
      end
    end

    #: () -> String
    def to_s
      "(#{@start}..#{@stop})"
    end
  end
end
