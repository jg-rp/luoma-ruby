# frozen_string_literal: true

module Luoma
  class ChoiceLoader < TemplateLoader
    def initialize(*loaders)
      super
      @loaders = loaders
    end

    def load(env, name, **kwargs)
      @loaders.each do |loader|
        return loader.load(env, name, **kwargs)
      rescue TemplateNotFoundError
        next
      end

      raise TemplateNotFoundError.new("template not found #{name.inspect}")
    end
  end
end
