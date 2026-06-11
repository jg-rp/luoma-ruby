# frozen_string_literal: true

require_relative "chain_hash"

module Luoma
  class RenderContext
    attr_reader :env, :template, :disabled_tags, :context_depth, :assign_score, :assign_score_cumulative,
                :registers

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

      # The Liquid environment this render context and associated template is
      # bound to.
      @env = template.env

      # Developer-defined template variables passed down from the environment
      # and template.
      @globals = globals || {} # steep:ignore

      # The namespace for variables defined with `{% assign %}` and
      # `{% capture %}`.
      @locals = {} #: Hash[String, untyped]

      # A namespace for `{% increment %}` and `{% decrement %}`.
      @counters = {} #: Hash[String, untyped]

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
      @assign_score_cumulative = assign_score_carry || 0

      # The number of nodes rendered for the current template.
      @render_score = 0

      # The number of nodes rendered for the current template and all partial
      # templates.
      @render_score_cumulative = render_score_carry || 0

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

    # Follow path segments starting at `obj`. If the path from `obj` does not
    # exist, :nothing is returned along with the index of the last segment to
    # be successfully resolved.
    #
    #: (untyped, Array[untyped]) -> [untyped, Integer]
    def resolve_path(obj, segments)
      segment_index = -1

      segments.each do |segment|
        segment_index += 1

        obj = case obj
              when Drop
                segment = segment.to_primitive(:string, self) if segment.is_a?(Drop)
                if obj.key?(segment, self)
                  obj.fetch(segment, self)
                else
                  :nothing
                end
              when Array
                segment = segment.to_primitive(:numeric, self) if segment.is_a?(Drop)
                resolve_array_segment(obj, segment)
              when String
                resolve_string_segment(obj, segment)
              when Hash
                segment = segment.to_primitive(:data, self) if segment.is_a?(Drop)
                resolve_hash_segment(obj, segment)
              else
                resolve_unknown_segment(obj, segment)
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
    #: (_Namespace, bool?, Set[String]?, Template?) -> RenderContext
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
    #: (_Namespace, ?template: Template?) { () -> untyped } -> void
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

      return obj[index] if index && index < obj.length

      case segment
      when "first"
        obj.first
      when "last"
        obj.last
      when "size"
        obj.length
      else
        :nothing
      end
    end

    #: (String, untyped) -> untyped
    def resolve_string_segment(obj, segment)
      case segment
      when "first"
        obj[0]
      when "last"
        obj[-1]
      when "size"
        obj.length
      else
        :nothing
      end
    end

    #: (Hash[untyped, untyped], untyped) -> untyped
    def resolve_hash_segment(obj, segment)
      return obj[segment] if obj.key?(segment)

      case segment
      when "first"
        obj.first
      when "size"
        obj.size
      else
        :nothing
      end
    end

    #: (untyped, untyped) -> untyped
    def resolve_unknown_segment(obj, segment)
      if segment == "size" && obj.respond_to?(:size)
        obj.size
      elsif segment == "first" && obj.respond_to?(:first)
        obj.first
      elsif segment == "last" && obj.respond_to?(:last)
        obj.last
      else
        :nothing
      end
    end
  end
end
