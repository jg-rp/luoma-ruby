# frozen_string_literal: true

module Luoma
  class IfChangedTag < Markup
    END_IFCHANGED_BLOCK = Set["endifchanged"]

    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      block = parser.parse_block(stop: END_IFCHANGED_BLOCK)
      parser.eat_empty_tag("endifchanged")
      new(token, tag_name, block)
    end

    def initialize(token, tag_name, block)
      super(token)
      @tag_name = tag_name
      @block = block
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      buf = +""
      Luoma.render_block(@block, context, buf)

      last = context.registers[:ifchanged]
      unless buf == last
        buffer << buf
        context.registers[:ifchanged] = buf
      end
    end

    #: (RenderContext) -> Array[Markup]
    def children(static_context)
      @block.grep_v(String) #: Array[Markup]
    end
  end
end
