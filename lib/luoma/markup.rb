# frozen_string_literal: true

module Luoma
  # The base class for all tag nodes and the output statement.
  class Markup
    attr_reader :token, :blank, :tag_name

    #: (t_token) -> void
    def initialize(token)
      @token = token
      @blank = false
      @tag_name = ""
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      raise "not implemented"
    end

    #: (RenderContext) -> Array[Markup]
    def children(static_context)
      []
    end

    #: () -> Array[Expression]
    def expressions
      []
    end

    #: () -> Array[Name]
    def block_scope
      []
    end

    #: () -> Array[Name]
    def template_scope
      []
    end

    #: (RenderContext) -> Partial?
    def partial(static_context)
      nil
    end
  end

  class Partial
    attr_reader :template, :scope_kind, :in_scope, :key

    #: (Template, :shared | :isolated | :inherited, Array[Name], Integer) -> void
    def initialize(template, scope_kind, in_scope, key)
      @template = template
      @scope_kind = scope_kind
      @in_scope = in_scope
      @key = key
    end
  end

  #: (t_block, RenderContext, String, ?root: false) -> void
  def self.render_block(block, context, buffer, root: false)
    if context.env.max_render_score || context.env.max_render_score_cumulative
      context.render_score += block.length
      context.render_score_cumulative += block.length

      if (context.env.max_render_score && context.render_score > context.env.max_render_score) ||
         (context.env.max_render_score_cumulative &&
          context.render_score_cumulative > context.env.max_render_score_cumulative)
        raise ResourceLimitError.new("memory limits reached")
      end
    end

    block.each do |node|
      if node.is_a?(String)
        buffer << node
      else
        if context.disabled_tags&.include?(node.tag_name)
          raise DisabledTagError.new(
            "#{node.tag_name.inspect} is not allowed in this context",
            node.token,
            context.template.source,
            context.template.name
          )
        end

        node.render(context, buffer)

        # TODO: disable these when strict is false?
        if root && !context.interrupts.empty?
          raise TemplateSyntaxError.new(
            "unexpected #{context.interrupts.last}",
            node.token,
            context.template.source,
            context.template.name
          )
        end
      end

      if context.env.max_render_size && buffer.bytesize > context.env.max_render_size
        raise ResourceLimitError.new("memory limits exceeded")
      end

      break unless context.interrupts.empty?
    end
  end

  #: (t_block) -> bool
  def self.blank_block?(block)
    block.all? { |node| node.is_a?(String) ? node.match?(/\A\s*\Z/) : node.blank }
  end
end
