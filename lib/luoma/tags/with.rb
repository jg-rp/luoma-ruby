# frozen_string_literal: true

module Luoma
  class WithTag < Markup
    END_WITH_BLOCK = Set["endwith"]

    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      args = parser.parse_keyword_arguments(require_commas: true)
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      block = parser.parse_block(stop: END_WITH_BLOCK)
      parser.eat_empty_tag("endwith")
      new(token, tag_name, args, block)
    end

    #: (t_token, String, Array[KeywordArgument], t_block) -> void
    def initialize(token, tag_name, args, block)
      super(token)
      @tag_name = tag_name
      @args = args
      @block = block
      @blank = Luoma.blank_block?(block)
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      scope = {} #: t_namespace

      context.extends(scope) do
        # NOTE: Later arguments can use earlier arguments.
        @args.each do |arg|
          scope[arg.name.value] = arg.expression.evaluate(context)
        end

        Luoma.render_block(@block, context, buffer)
      end
    end

    #: (RenderContext) -> Array[Markup]
    def children(static_context)
      @block.grep_v(String) #: Array[Markup]
    end

    #: () -> Array[Expression]
    def expressions
      @args.map(&:expression)
    end

    #: () -> Array[Name]
    def block_scope
      @args.map(&:name)
    end
  end
end
