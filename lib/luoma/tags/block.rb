# frozen_string_literal: true

module Luoma
  class BlockTag < Markup
    END_BLOCK = Set["endblock"]

    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      identifier = parser.parse_ident
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      block = parser.parse_block(stop: END_BLOCK)
      parser.eat_empty_tag("endblock")
      new(token, tag_name, identifier, block)
    end

    #: (t_token, String, Name, t_block) -> void
    def initialize(token, tag_name, identifier, block)
      super(token)
      @tag_name = tag_name
      @identifier = identifier
      @block = block
      @blank = true
      @drop = BlockDrop.new(@block)
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      context.assign(@identifier.value, @drop)
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
