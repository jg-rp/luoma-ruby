# frozen_string_literal: true

module Luoma
  class ContinueTag < Markup
    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      new(token, tag_name)
    end

    def initialize(token, tag_name)
      super(token)
      @tag_name = tag_name
      @blank = true
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      context.interrupts.push(:break)
    end
  end
end
