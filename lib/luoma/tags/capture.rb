# frozen_string_literal: true

module Luoma
  class CaptureTag < Markup
    END_CAPTURE_BLOCK = Set["endcapture"]

    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      identifier = parser.parse_ident
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      block = parser.parse_block(stop: END_CAPTURE_BLOCK)
      parser.eat_empty_tag("endcapture")
      new(token, tag_name, identifier, block)
    end

    #: (t_token, String, Name, t_block) -> void
    def initialize(token, tag_name, identifier, block)
      super(token)
      @tag_name = tag_name
      @identifier = identifier
      @block = block
      @blank = true
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      buf = +""
      Luoma.render_block(@block, context, buf)
      context.assign(@identifier.value, buf)
    end

    #: (RenderContext) -> Array[Markup]
    def children(static_context)
      @block.grep_v(String) #: Array[Markup]
    end

    #: () -> Array[Name]
    def template_scope
      [@identifier]
    end
  end
end
