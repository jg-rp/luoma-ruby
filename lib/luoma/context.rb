# frozen_string_literal: true

require_relative "chain_hash"

module Luoma
  class RenderContext
    attr_reader :env, :template, :disabled_tags, :context_depth, :assign_score, :assign_score_cumulative,
                :registers, :globals, :scopes, :locals

    attr_accessor :render_score, :render_score_cumulative, :interrupts

    #: (Template, ?globals: _Namespace?) -> void
    def initialize(
      template,
      globals: nil,
      disabled_tags: nil,
      context_depth: nil,
      assign_score_carry: nil,
      render_score_carry: nil
    )
      # The template being rendered.
      @template = template

      # The environment this render context and associated template is
      # bound to.
      @env = template.env

      # Developer-defined template variables passed down from the environment
      # and template.
      @globals = globals || {} # steep:ignore

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
      @scopes = ChainHash.new(@counters, @globals, @locals)

      # Names of tags that are disallowed in this context.
      @disabled_tags = disabled_tags

      # The number of times this render context has been extended or copied.
      @context_depth = context_depth || 0

      # A non-specific indicator of template local scope usage.
      @assign_score = 0

      # A non-specific indicator of template local scope usage for the current
      # template and all partial templates combined.
      @assign_score_cumulative = assign_score_carry || 0

      # The number of nodes rendered for the current template.
      @render_score = 0

      # The number of nodes rendered for the current template and all partial
      # templates.
      @render_score_cumulative = render_score_carry || 0

      # A stack of interrupt signals used by `{% break %}` and
      # `{% continue %}`, for example.
      @interrupts = [] #: Array[Symbol]

      # Registers supporting stateful tags. It's OK to use this map for storing
      # custom tag state.
      @registers = {
        cycles: Hash.new(0)
      }
    end

    #: (String) -> untyped
    def resolve(name)
      @scopes[name]
    end

    # Follow path segments starting at `obj`. If the path from `obj` does not
    # exist, :nothing is returned along with the index of the last segment to
    # be successfully resolved.
    #
    #: (untyped, Array[untyped]) -> [untyped, Integer]
    def resolve_path(obj, segments)
      segment_index = -1

      segments.each do |segment|
        segment_index += 1

        return [segment.call(self, obj), segment_index] if segment.is_a?(PredicateFunction)

        obj = case obj
              when Drop
                segment = segment.to_primitive(:string, self) if segment.is_a?(Drop)
                obj.fetch(segment, self, default: :nothing)
              when Array
                segment = segment.to_primitive(:numeric, self) if segment.is_a?(Drop)
                resolve_array_segment(obj, segment)
              when Hash
                segment = segment.to_primitive(:data, self) if segment.is_a?(Drop)
                resolve_hash_segment(obj, segment)
              else
                :nothing
              end

        return [:nothing, segment_index] if obj == :nothing
      end

      [obj, segment_index]
    end

    #: (String, untyped) -> void
    def assign(name, value)
      if @env.max_assign_score || @env.max_assign_score_cumulative
        score = assign_score_of(value)
        @assign_score += score
        @assign_score_cumulative += score

        if (@env.max_assign_score && @assign_score > @env.max_assign_score) || # steep:ignore
           (@env.max_assign_score_cumulative &&
            @assign_score_cumulative > @env.max_assign_score_cumulative) # steep:ignore
          raise ResourceLimitError.new("memory limits reached")
        end

      end

      @locals[name] = value
    end

    # Return a new render context with render state from this context.
    #
    # The caller is responsible for updating renderScoreCumulative when the new
    # context is no longer needed.
    #: (t_namespace, bool?, Set[String]?, Template?) -> RenderContext
    def copy(namespace, block_scope: nil, disabled_tags: nil, template: nil)
      ctx = RenderContext.new(
        template || @template,
        globals: block_scope ? ChainHash.new(namespace, @scopes) : ChainHash.new(namespace, @globals),
        context_depth: @context_depth + 1,
        assign_score_carry: @assign_score_cumulative,
        render_score_carry: @assign_score_cumulative
      )

      @env.persistent_registers.each { |r| ctx.registers[r] = @registers[r] if @registers.include?(r) }
      ctx
    end

    # Extend the scope of this context with the given namespace for the
    # duration of a block.
    #
    #: (t_namespace, ?template: Template?) { () -> untyped } -> void
    def extends(namespace, template: nil)
      raise_for_context_depth

      assign_score_ = @assign_score
      render_score_ = @render_score
      template_ = @template

      @template = template if template
      @scopes << namespace
      @context_depth += 1
      @assign_score = 0
      @render_score = 0

      begin
        yield
      ensure
        @template = template_ if template
        @scopes.pop
        @context_depth -= 1
        @assign_score = assign_score_
        @render_score = render_score_
      end
    end

    #: (String) -> Integer
    def decrement(name)
      value = (@counters[name] || 0) - 1
      @counters[name] = value
      value
    end

    #: (String) -> Integer
    def increment(name)
      value = @counters[name] || 0
      @counters[name] = value + 1
      value
    end

    private

    #: () -> void
    def raise_for_context_depth
      if @context_depth + 1 > @env.max_context_depth
        raise ContextDepthError.new(
          "maximum context depth reached, possible recursive render"
        )
      end
    end

    #: (untyped) -> Integer
    def assign_score_of(value)
      case value
      when String
        value.bytesize
      when Array
        value.sum { |i| assign_score_of(i) } + 1
      when Hash
        value.reduce(1) { |a, p| a + assign_score_of(p.first) + assign_score_of(p.last) }
      else
        1
      end
    end

    #: (Array[untyped], untyped) -> untyped
    def resolve_array_segment(obj, segment)
      index = if segment.is_a?(Integer)
                segment.negative? && obj.length >= segment.abs ? obj.length + segment : segment
              end

      if index && index < obj.length
        obj[index]
      else
        :nothing
      end
    end

    #: (Hash[untyped, untyped], untyped) -> untyped
    def resolve_hash_segment(obj, segment)
      if obj.key?(segment)
        obj[segment]
      else
        :nothing
      end
    end
  end
end
