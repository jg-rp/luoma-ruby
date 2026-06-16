# frozen_string_literal: true

module Luoma
  class ElseBlock < Markup
    attr_reader :expression, :block

    #: (t_token, String, t_block) -> void
    def initialize(token, tag_name, block)
      super(token)
      @tag_name = tag_name
      @expression = BooleanLiteral.new(token, true)
      @block = block
      @blank = Luoma.blank_block?(block)
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      Luoma.render_block(@block, context, buffer)
    end

    #: (RenderContext) -> Array[Markup]
    def children(static_context)
      @block.grep_v(String) #: Array[Markup]
    end

    def filter_strings
      @block.filter! { |node| !node.is_a?(String) }
    end
  end
end
