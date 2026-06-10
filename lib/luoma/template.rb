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

    #: (_Namespace?) -> String
    def render(data)
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

    #: (_Namespace) -> Template
    def with_globals(namespace)
      raise "TODO:"
    end

    # TODO: static analysis methods

    protected

    #: (_Namespace?) -> _Namespace?
    def make_globals(namespace)
      raise "TODO:"
    end
  end
end
