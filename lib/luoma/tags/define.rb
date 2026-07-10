# frozen_string_literal: true

module Luoma
  class DefineTag < Markup
    END_DEFINE_BLOCK = Set["enddefine"]

    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      identifier = parser.parse_ident

      if parser.kind == :token_assign
        # An inline `define` tag binding a lambda expression to name.
        parser.next
        expr = parser.parse_lambda_expression
        parser.carry_whitespace_control
        parser.eat(:token_tag_end)
        new(token, tag_name, identifier, expr)
      else
        # A block-level `define` tag binding a block of markup to a name.
        parser.carry_whitespace_control
        parser.eat(:token_tag_end)

        block = parser.parse_block(stop: END_DEFINE_BLOCK)
        parser.eat_empty_tag("enddefine")
        new(token, tag_name, identifier, block)
      end
    end

    #: (t_token, String, Name, t_block | Lambda) -> void
    def initialize(token, tag_name, identifier, block_or_expr)
      super(token)
      @tag_name = tag_name
      @identifier = identifier
      @block_or_expr = block_or_expr
      @blank = true
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      drop = if @block_or_expr.is_a?(Lambda)
               ExpressionDrop.new(@block_or_expr.evaluate(context)) # steep:ignore
             else
               BlockDrop.new(@block_or_expr) # steep:ignore
             end

      context.assign(@identifier.value, drop)
    end

    #: (RenderContext) -> Array[Markup]
    def children(static_context)
      @block.grep_v(String) #: Array[Markup]
    end

    #: () -> Array[Name]
    def template_scope
      [@identifier]
    end
  end
end
