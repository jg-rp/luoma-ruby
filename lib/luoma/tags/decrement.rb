# frozen_string_literal: true

module Luoma
  class DecrementTag < Markup
    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      identifier = parser.parse_ident
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      new(token, tag_name, identifier)
    end

    #: (t_token, String, Name) -> void
    def initialize(token, tag_name, identifier)
      super(token)
      @blank = false
      @tag_name = tag_name
      @identifier = identifier
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      buffer << context.decrement(@identifier.value).to_s
    end

    #: () -> Array[Name]
    def template_scope
      [@identifier]
    end
  end
end
