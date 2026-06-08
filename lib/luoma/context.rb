# frozen_string_literal: true

module Luoma
  class RenderContext
    attr_reader :env, :template

    #: (Template, ?globals: t_namespace?) -> void
    def initialize(template, globals: nil)
      @template = template
      @env = template.env
    end
  end
end
