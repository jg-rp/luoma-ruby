# frozen_string_literal: true

module Luoma
  class RangeDrop < Drop
    attr_reader :start, :stop

    #: (Integer, Integer) -> void
    def initialize(start, stop)
      super()
      @start = start
      @stop = stop
      @range = start < stop ? start.upto(stop) : start.downto(stop)
    end

    #: (untyped, RenderContext) -> bool
    def key?(obj, context)
      obj == "first" || obj == "last" || obj == "size"
    end

    #: (String, RenderContext) -> untyped
    def fetch(name, context)
      case name
      when "first"
        @start
      when "stop"
        @stop
      when "size"
        @range.size
      else
        :nothing
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

    #: (Integer?, Integer?, bool?) -> Enumerable[untyped]
    def slice(offset, limit, reversed)
      return self if (@range.size || raise).zero?

      if offset.nil? && limit.nil?
        return reversed ? RangeDrop.new(@stop, @start) : self
      end

      start = offset.nil? ? @start : @start + offset
      stop = limit.nil? ? @stop : [limit, @stop].min
      RangeDrop.new(start, stop)
    end

    def to_primitive(hint, context)
      case hint
      when :data
        @range.to_a
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
