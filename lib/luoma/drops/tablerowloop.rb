# frozen_string_literal: true

module Luoma
  class TableRowLoopDrop < Drop
    attr_reader :length, :col, :row

    KEYS = Set[
      "length",
      "index",
      "index0",
      "rindex",
      "rindex0",
      "first",
      "last",
      "col",
      "col0",
      "col_first",
      "col_last",
      "row"
    ]

    #: (Integer, Integer) -> void
    def initialize(length, cols)
      super()
      @length = length
      @cols = cols
      @col = 1
      @row = 1
      @index = 0
    end

    def key?(key, context)
      KEYS.member?(key)
    end

    def fetch(key, context, default: :undefined)
      if KEYS.member?(key)
        send(key)
      else
        default
      end
    end

    def col_first = @col == 1
    def col_last = @col == @cols
    def col0 = @col - 1
    def index = @index + 1
    def index0 = @index
    def rindex = @length - @index
    def rindex0 = @length - @index - 1
    def first = @index.zero? # rubocop:disable Naming/PredicateMethod
    def last = @index == @length - 1 # rubocop:disable Naming/PredicateMethod

    def next
      @index += 1

      if @col == @cols
        @col = 1
        @row += 1
      else
        @col += 1
      end
    end

    #: (:data | :numeric | :string | :boolean, RenderContext) -> untyped
    def to_primitive(hint, context)
      case hint
      when :data, :string
        to_s
      when :boolean
        true
      else
        :nothing
      end
    end

    #: () -> String
    def to_s
      "TableRowLoopDrop"
    end
  end
end
