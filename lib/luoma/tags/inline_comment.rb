# frozen_string_literal: true

module Luoma
  class InlineCommentTag < Markup
    attr_reader :text

    RE_LEADING_HASH = /\n\s*[^#\s]/

    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      text_token = parser.eat(:token_comment)
      text = Luoma.get_token_value(text_token, parser.source)

      if RE_LEADING_HASH.match?(text)
        raise TemplateSyntaxError.new(
          "every inline comment line must start with a '#'",
          text_token,
          parser.source,
          parser.template_name
        )
      end

      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      new(token, tag_name, text)
    end

    #: (t_token, String, String) -> void
    def initialize(token, tag_name, text)
      super(token)
      @blank = true
      @tag_name = tag_name
      @text = text
    end

    #: (RenderContext, String) -> void
    def render(context, buffer); end
  end
end
