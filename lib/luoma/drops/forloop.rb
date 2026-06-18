# frozen_string_literal: true

module Luoma
  class ForLoopDrop < Drop
    attr_reader :name, :length, :parentloop

    KEYS = Set[
      "name",
      "length",
      "index",
      "index0",
      "rindex",
      "rindex0",
      "first",
      "last",
      "parentloop"
    ]

    #: (String, Integer, ForLoopDrop?) -> void
    def initialize(name, length, parent)
      super()
      @name = name
      @length = length
      @parentloop = parent
      @index = -1
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

    def next = @index += 1
    def index = @index + 1
    def index0 = @index
    def rindex = @length - @index
    def rindex0 = @length - @index - 1
    def first = @index.zero? # rubocop:disable Naming/PredicateMethod
    def last = @index == @length - 1 # rubocop:disable Naming/PredicateMethod

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
      "Liquid::ForLoopDrop"
    end
  end
end
