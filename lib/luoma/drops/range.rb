# frozen_string_literal: true

module Luoma
  class RangeDrop < Drop
    attr_reader :start, :stop

    def initialize(start, stop)
      super()
      @start = start
      @stop = stop
      @range = (start...stop)
    end

    def each(&block)
      return enum_for(:each) unless block

      @range
    end

    #: (untyped, RenderContext) -> bool
    def eq?(obj, context)
      obj.is_a?(RangeDrop) && obj.start == obj.stop
    end

    def slice(offset, limit, reversed)
      array = @range.to_a
      array = array.slice(offset || 0, limit || array.length) || []
      reversed ? array.reverse! : array
    end

    #: (:data | :numeric | :string | :boolean, RenderContext) -> untyped
    def to_primitive(hint, context)
      case hint
      when :data
        @range.to_a
      when :numeric
        0
      when :string
        ""
      when :boolean
        false
      end
    end
  end
end
