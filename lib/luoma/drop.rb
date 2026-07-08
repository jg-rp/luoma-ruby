# frozen_string_literal: true

module Luoma
  class Drop
    include Enumerable

    #: (untyped, RenderContext) -> bool
    def key?(obj, context)
      false
    end

    #: (String, RenderContext) -> untyped
    def fetch(name, context, default: :nothing)
      default
    end

    def each(&block)
      return enum_for(:each) unless block

      [].to_enum # steep:ignore
    end

    def to_a
      each.to_a
    end

    #: (untyped, RenderContext) -> bool
    def eq?(obj, context)
      false
    end

    #: (untyped, RenderContext) -> bool
    def lt?(obj, context)
      false
    end

    #: (untyped, RenderContext) -> bool
    def gt?(obj, context)
      false
    end

    #: (obj, RenderContext) -> bool
    def contains?(obj, context)
      false
    end

    # Return the length of this object.
    # Along with `#slice`,  `#length` is part of the iterator protocol.
    #: (RenderContext) -> Integer
    def length(context)
      0
    end

    # TODO: pass context
    #: (Integer, Integer, Integer) -> Enumerable[untyped]
    def slice(start, stop, step)
      self
    end

    #: (:data | :numeric | :string | :boolean, RenderContext) -> untyped
    def to_primitive(hint, context)
      case hint
      when :data
        nil
      when :numeric
        0
      when :string
        ""
      when :boolean
        false
      end
    end

    #: () -> String
    def to_s
      ""
    end

    #: () -> String?
    def to_html_safe_s
      nil
    end
  end
end
