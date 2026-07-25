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
    #
    # _isolated_ templates raise errors for orphaned `{% break %}` and
    # `{% continue %}` tags.
    #
    #: (RenderContext, String, ?isolated: bool) -> String
    def render_with_context(context, buffer, isolated: true)
      Luoma.render_block(@nodes, context, buffer, root: isolated)
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

    # Return `false` if this template is stale and needs to be loaded again.
    # `nil` is returned if an `up_to_date` proc is not available.
    def up_to_date?
      @up_to_date&.call
    end

    # TODO: static analysis methods

    # Statically analyze this template and report variable, tag and filter usage.
    #
    #: (?include_partials: bool) -> Luoma::StaticAnalysis::Result
    def analyze(include_partials: false)
      Luoma::StaticAnalysis.analyze(self, include_partials: include_partials)
    end

    # Return an array of variable names used in this template, without path segments.
    #
    #: (?include_partials: bool) -> Array[String]
    def variables(include_partials: false)
      analyze(include_partials: include_partials).variables.keys
    end

    # Return an array of variables used in this template, including path segments.
    #
    #: (?include_partials: bool) -> Array[String]
    def variable_paths(include_partials: false)
      analyze(include_partials: include_partials).variables.values.flatten.map { |v| v[:path] }.uniq
    end

    # Return an array of variables used in this template, each as an array of segments.
    #
    #: (?include_partials: bool) -> Array[Segments]
    def variable_segments(include_partials: false)
      analyze(include_partials: include_partials).variables.values.flatten.map { |v| v[:segments] }.uniq
    end

    # Return an array of global variables used in this template, without path segments.
    #
    #: (?include_partials: bool) -> Array[String]
    def global_variables(include_partials: false)
      analyze(include_partials: include_partials).globals.keys
    end

    # Return an array of global variables used in this template, including path segments.
    #
    #: (?include_partials: bool) -> Array[String]
    def global_variable_paths(include_partials: false)
      analyze(include_partials: include_partials).globals.values.flatten.map { |v| v[:path] }.uniq
    end

    # Return an array of global variables used in this template, each as an array of segments.
    #
    #: (?include_partials: bool) -> Array[Segments]
    def global_variable_segments(include_partials: false)
      analyze(include_partials: include_partials).globals.values.flatten.map { |v| v[:segments] }.uniq
    end

    # Return the names of all filters used in this template.
    #
    #: (?include_partials: bool) -> Array[String]
    def filter_names(include_partials: false)
      analyze(include_partials: include_partials).filters.keys
    end

    # Return the names of all tags used in this template.
    #
    #: (?include_partials: bool) -> Array[String]
    def tag_names(include_partials: false)
      analyze(include_partials: include_partials).tags.keys
    end

    # Return an array of comment nodes found in this template.
    #
    # Comment nodes have `token` and `text` attributes. Use `template.comments.map(&:text)`
    # to get an array of comment strings. Each comment string includes leading and trailing
    # whitespace.
    #
    # Note that this method does not try to load included or render templates when looking.
    # for comment nodes.
    #
    #: () -> Array[Comment]
    def comments
      context = RenderContext.new(self)
      nodes = [] # : Array[Comment]

      # @type var visit: ^(Markup) -> void
      visit = lambda do |node|
        nodes << node if node.is_a?(Comment)

        node.children(context).each do |child|
          visit.call(child)
        end
      end

      @nodes.each { |node| visit.call(node) unless node.is_a?(String) }

      nodes
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
