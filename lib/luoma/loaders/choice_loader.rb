# frozen_string_literal: true

module Luoma
  class ChoiceLoader < TemplateLoader
    #: (*TemplateLoader) -> void
    def initialize(*loaders)
      super()
      @loaders = loaders
    end

    #: (Environment, String, ?globals: t_namespace?, ?context: RenderContext?, **kwargs) -> Template
    def load(env, name, globals: nil, context: nil, **)
      @loaders.each do |loader|
        return loader.load(env, name, globals: globals, context: context, **)
      rescue TemplateNotFoundError
        next
      end

      raise TemplateNotFoundError.new("template not found #{name.inspect}")
    end
  end
end
