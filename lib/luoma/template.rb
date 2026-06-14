module Luoma
  class Template
    attr_reader :env, :source, :nodes, :globals, :name, :overlay, :up_to_date

    #: (Environment,
    #   String,
    #   t_block,
    #   ?globals: _Namespace?,
    #   ?name: String?,
    #   ?overlay: _Namespace?,
    #   ?up_to_date: Proc::_Callable?) -> void
    def initialize(env, source, nodes, globals: nil, name: nil, overlay: nil, up_to_date: nil)
      @env = env
      @source = source
      @nodes = nodes
      @globals = globals
      @name = name || ""
      @overlay = overlay
      @up_to_date = up_to_date
    end

    # Render this template with template variables from `data`.
    #: (_Namespace?) -> String
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
    #: (_Namespace) -> Template
    def with_globals(globals)
      Template.new(
        @env, @source, @nodes,
        globals: globals,
        name: @name,
        overlay: @overlay,
        up_to_date: @up_to_date
      )
    end

    # TODO: static analysis methods

    protected

    # Return a new namespace including data from `namespace` and other
    # namespaces pinned to this template.
    #: (_Namespace?) -> _Namespace?
    def make_globals(namespace)
      namespaces = [namespace, @overlay, @globals].compact
      ChainHash.new(*namespaces) unless namespaces.empty?
    end
  end
end
