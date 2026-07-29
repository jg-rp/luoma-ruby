# frozen_string_literal: true

module Luoma
  # The base class for all template loaders.
  class TemplateLoader
    # Load and return template source text and any associated data.
    #: (Environment, String, ?context: RenderContext?, **untyped) -> TemplateSource
    def get_source(env, name, context: nil, **kwargs)
      raise "not implemented"
    end

    #: (Environment, String, ?globals: t_namespace?, ?context: RenderContext?, **kwargs) -> Template
    def load(env, name, globals: nil, context: nil, **kwargs)
      data = get_source(env, name, context: context, **kwargs)
      env.parse(data.source,
                name: data.name,
                globals: globals,
                up_to_date: data.up_to_date,
                overlay: data.matter)
    end
  end

  # Template source text and meta data.
  class TemplateSource
    attr_accessor :source, :name, :up_to_date, :matter

    def initialize(source:, name:, up_to_date: nil, matter: nil)
      @source = source
      @name = name
      @up_to_date = up_to_date
      @matter = matter
    end
  end

  # A template loader that reads templates from a hash.
  class HashLoader < TemplateLoader
    #: (Hash<String, String>) -> void
    def initialize(templates)
      super()
      @templates = templates
    end

    def get_source(env, name, context: nil, **kwargs)
      source = @templates[name]
      raise TemplateNotFoundError.new("template not found #{name}") unless source

      TemplateSource.new(source: source, name: name)
    end
  end
end
