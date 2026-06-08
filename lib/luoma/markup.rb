# frozen_string_literal: true

module Luoma
  # The base class for all tag nodes and the output statement.
  class Markup
    attr_reader :token, :blank, :tag

    #: (t_token) -> void
    def initialize(token)
      @token = token
      @blank = false
      @tag = ""
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      raise "not implemented"
    end

    #: (RenderContext) -> Array[Markup]
    def children(static_context)
      []
    end

    #: () -> Array[Expression]
    def expressions
      []
    end

    #: () -> Array[Name]
    def block_scope
      []
    end

    #: (RenderContext) -> Partial?
    def partial(static_context)
      nil
    end
  end

  class Partial
    attr_reader :template, :scope_kind, :in_scope, :key

    #: (Template, :shared | :isolated | :inherited, Array[Name], Integer) -> void
    def initialize(template, scope_kind, in_scope, key)
      @template = template
      @scope_kind = scope_kind
      @in_scope = in_scope
      @key = key
    end
  end

  #: (t_block, RenderContext, String) -> void
  def self.render_block(block, context, buffer)
    raise "TODO:"
  end

  #: (t_block) -> bool
  def self.blank_block?(block)
    raise "TODO:"
  end
end
