# frozen_string_literal: true

module Luoma
  class LiquidTag < Markup
    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      block = parser.parse_line_statements
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      new(token, tag_name, block)
    end

    #: (t_token, String, String) -> void
    def initialize(token, tag_name, block)
      super(token)
      @tag_name = tag_name
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
  end
end
