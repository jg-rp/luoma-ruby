# frozen_string_literal: true

module Luoma
  class RangeDrop < Drop
    attr_reader :start, :stop

    def initialize(start, stop)
      super()
      @start = start
      @stop = stop
      @range = (start..stop)
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

    def to_a
      @range.to_a
    end

    def each(&)
      @range.each
    end

    #: (untyped, RenderContext) -> bool
    def eq?(obj, context)
      obj.is_a?(RangeDrop) && obj.start == obj.stop
    end

    #: (RenderContext) -> Integer
    def length(context) # steep:ignore
      @range.size
    end

    def slice(start, stop, step)
      @range.to_a[(start...stop).step(step)] # steep:ignore
    end

    #: (:data | :numeric | :string | :boolean, RenderContext) -> untyped
    def to_primitive(hint, context)
      case hint
      when :data
        @range.to_a
      when :numeric
        :nothing
      when :string
        JSON.generate(@range.to_a)
      when :boolean
        false
      end
    end
  end
end
