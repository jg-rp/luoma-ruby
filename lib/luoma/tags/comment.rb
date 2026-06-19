# frozen_string_literal: true

module Luoma
  class CommentTag < Markup
    attr_reader :text

    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      comment_token = parser.eat(:token_comment)
      parser.eat_empty_tag("endcomment")
      new(token, tag_name, Luoma.get_token_value(comment_token, parser.source))
    end

    #: (t_token, String, String) -> void
    def initialize(token, tag_name, text)
      super(token)
      @tag_name = tag_name
      @text = text
      @blank = true
    end

    #: (RenderContext, String) -> void
    def render(context, buffer) end
  end
end
