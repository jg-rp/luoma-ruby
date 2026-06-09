# frozen_string_literal: true

require_relative "chain_hash"

module Luoma
  class RenderContext
    attr_reader :env, :template, :disabled_tags, :context_depth, :assign_score, :assign_score_cumulative,
                :registers

    attr_accessor :render_score, :render_score_cumulative, :interrupts

    #: (Template, ?globals: t_namespace?) -> void
    def initialize(
      template,
      globals: nil,
      disabled_tags: nil,
      context_depth: nil,
      assign_score_cumulative: nil,
      render_score_cumulative: nil
    )
      # The template being rendered.
      @template = template

      # The Liquid environment this render context and associated template is
      # bound to.
      @env = template.env

      # Developer-defined template variables passed down from the environment
      # and template.
      @globals = globals || {} #: t_namespace

      # The namespace for variables defined with `{% assign %}` and
      # `{% capture %}`.
      @locals = {} #: t_namespace

      # A namespace for `{% increment %}` and `{% decrement %}`.
      @counters = {} #: t_namespace

      # The current template scope including `locals`, `globals` and `counters`.
      # New block-scoped namespaces get pushed onto and popped off this chain
      # map.
      #
      # Scopes are searched from right to left. New scopes are push on the
      # right.
      @scopes = ChainHash.new(@locals, @globals, @counters)

      # Names of tags that are disallowed in this context.
      @disabled_tags = disabled_tags

      # The number of times this render context has been extended or copied.
      @context_depth = context_depth || 0

      # A non-specific indicator of template local scope usage.
      @assign_score = 0

      # A non-specific indicator of template local scope usage for the current
      # template and all partial templates combined.
      @assign_score_cumulative = assign_score_cumulative || 0

      # The number of nodes rendered for the current template.
      @render_score = 0

      # The number of nodes rendered for the current template and all partial
      # templates.
      @render_score_cumulative = render_score_cumulative || 0

      # A stack of interrupt signals used by `{% break %}` and
      # `{% continue %}`, for example.
      @interrupts = [] #: Array[Symbol]

      # A stack of `ForLoop` drops used to populate `forloop.parent`
      @forloops = [] #: Array[ForLoop]

      # Registers supporting stateful tags. It's OK to use this map for storing
      # custom tag state.
      @registers = {
        cycles: Hash.new(0),
        stop_index: {}, #: Hash[String, Integer]
        extends: Hash.new { |hash, key| hash[key] = [] },
        macros: {} #: Hash[String, untyped]
      }
    end

    #: (String) -> untyped
    def resolve(name)
      @scopes[name]
    end

    #: (untyped, Array[untyped]) -> untyped
    def resolve_path(obj, segments)
      raise "TODO"
    end

    #: (String, untyped) -> void
    def assign(name, value)
      raise "TODO"
    end

    #: (t_namespace, bool?, Set[String]?, Template?) -> RenderContext
    def copy(namespace, block_scope: nil, disabled_tags: nil, template: nil)
      raise "TODO:"
    end

    #: (t_namespace, ?template: Template?) { () -> untyped } -> void
    def extends(namespace, template: nil)
      raise "TODO:"
    end

    #: (String) -> Integer
    def decrement(name)
      raise "TODO:"
    end

    #: (String) -> Integer
    def increment(name)
      raise "TODO:"
    end
  end
end
