# frozen_string_literal: true

module Luoma
  class Template
    attr_reader :env, :source, :nodes, :globals, :name, :overlay, :up_to_date

    #: (Environment,
    #   String,
    #   t_block,
    #   ?globals: t_namespace?,
    #   ?name: String?,
    #   ?overlay: t_namespace?,
    #   ?up_to_date: Proc::_Callable?) -> void
    def initialize(env, source, nodes, globals: nil, name: nil, overlay: nil, up_to_date: nil)
      @env = env
      @source = source
      @nodes = nodes
      @globals = globals
      @name = name || ""
      @overlay = overlay
      @up_to_date = up_to_date
      @lines = nil
    end

    # Render this template with template variables from `data`.
    #: (t_namespace?) -> String
    def render(data = nil)
      buffer = +""
      context = RenderContext.new(self, globals: make_globals(data))
      render_with_context(context, buffer)
    end

    # Render this template to `buffer` with data from `context`.
    # Returns buffer.
    #: (RenderContext, String) -> String
    def render_with_context(context, buffer)
      Luoma.render_block(@nodes, context, buffer)
      buffer
    end

    # Return a copy of this template with different globals.
    #: (t_namespace) -> Template
    def with_globals(globals)
      Template.new(
        @env, @source, @nodes,
        globals: globals,
        name: @name,
        overlay: @overlay,
        up_to_date: @up_to_date
      )
    end

    # Return this template's source code split into lines.
    #
    #: () -> Array[String]
    def lines
      @lines ||= @source.lines(chomp: false)
    end

    # TODO: static analysis methods

    # Statically analyze this template and report variable, tag and filter usage.
    #
    #: (?include_partials: bool) -> Luoma::StaticAnalysis::Result
    def analyze(include_partials: false)
      Luoma::StaticAnalysis.analyze(self, include_partials: include_partials)
    end

    protected

    # Return a new namespace including data from `namespace` and other
    # namespaces pinned to this template.
    #: (t_namespace?) -> t_namespace?
    def make_globals(namespace)
      return @globals if namespace.nil? && @overlay.nil?

      namespace_ = {} #: t_namespace
      namespace_.merge!(@globals) if @globals # steep:ignore
      namespace_.merge!(@overlay) if @overlay # steep:ignore
      namespace_.merge!(namespace) if namespace
      namespace_
    end
  end
end
