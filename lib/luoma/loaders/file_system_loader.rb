# frozen_string_literal: true

require "pathname"

module Luoma
  # A template loader that reads template from a file system.
  class FileSystemLoader < TemplateLoader
    def initialize(search_path, default_extension: nil)
      super()
      @search_path = if search_path.is_a?(Array)
                       search_path.map { |p| Pathname.new(p) }
                     else
                       [Pathname.new(search_path)]
                     end

      @default_extension = default_extension
    end

    def get_source(_env, name, context: nil, **_kwargs)
      path = resolve_path(name)
      mtime = path.mtime
      up_to_date = -> { path.mtime == mtime }
      TemplateSource.new(source: path.read, name: path.basename.to_s, up_to_date: up_to_date)
    end

    def resolve_path(template_name)
      template_path = Pathname.new(template_name)

      # Append the default file extension if needed.
      if @default_extension && template_path.extname.empty?
        template_path = template_path.sub_ext(@default_extension || raise)
      end

      # Search each path in turn.
      @search_path.each do |path|
        source_path = path.join(template_path)
        next unless child_path?(source_path, path)
        return source_path if source_path.file?
      end

      raise TemplateNotFoundError.new("template not found #{template_name}")
    end

    private

    #: (Pathname, Pathname) -> bool
    def child_path?(child, parent)
      child_ = child.expand_path
      parent_ = parent.expand_path
      child_.ascend.drop(1).include?(parent_)
    end
  end

  # A file system template loader that caches parsed templates.
  class CachingFileSystemLoader < FileSystemLoader
    include CachingLoaderMixin

    def initialize(
      search_path,
      default_extension: nil,
      auto_reload: true,
      namespace_key: "",
      capacity: 300,
      thread_safe: false
    )
      super(search_path, default_extension: default_extension)

      initialize_cache(
        auto_reload: auto_reload,
        namespace_key: namespace_key,
        capacity: capacity,
        thread_safe: thread_safe
      )
    end
  end
end
