module Luoma
  class RenderContext
    attr_reader :env, :template

    #: (Template) -> void
    def initialize(template)
      @template = template
      @env = template.env
    end
  end
end
