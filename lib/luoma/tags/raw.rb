# frozen_string_literal: true

module Luoma
  class RawTag < Markup
    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      text_token = parser.eat(:token_text)
      parser.eat_empty_tag("endraw")
      new(token, tag_name, Luoma.get_token_value(text_token, parser.source))
    end

    #: (t_token, String, String) -> void
    def initialize(token, tag_name, text)
      super(token)
      @tag_name = tag_name
      @text = text
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      buffer << @text
    end
  end
end
