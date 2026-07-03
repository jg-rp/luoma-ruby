# frozen_string_literal: true

module Luoma
  class Comment < Markup
    attr_reader :text

    #: (t_token, String) -> void
    def initialize(token, text)
      super(token)
      @text = text
      @blank = true
    end

    #: (RenderContext, String) -> void
    def render(context, buffer) end
  end
end
