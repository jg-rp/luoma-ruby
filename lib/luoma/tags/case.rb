# frozen_string_literal: true

module Luoma
  class CaseTag < Markup
    END_CASE_BLOCK = Set["endcase", "when", "else"]

    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      parser.expect_expression
      expression = parser.parse_expression
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)

      # Junk between `{% case %}` and first `{% when %}`.
      parser.eat(:token_text) if parser.kind == :token_text

      blocks = [] #: Array[WhenBlock|ElseBlock]
      blocks << WhenBlock.parse("when", parser) while parser.tag?("when")

      if parser.tag?("else")
        else_token = parser.eat_empty_tag("else")
        blocks << ElseBlock.new(
          else_token,
          "else",
          parser.parse_block(stop: END_CASE_BLOCK)
        )
      end

      parser.eat_empty_tag("endcase")
      new(token, tag_name, expression, blocks)
    end

    #: (t_token, String, Expression, Array[WhenBlock|ElseBlock]) -> void
    def initialize(token, tag_name, expression, blocks)
      super(token)
      @tag_name = tag_name
      @expression = expression
      @blocks = blocks
      @blank = blocks.all?(&:blank)
      @blocks.each(&:filter_strings) if @blank
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      left = @expression.evaluate(context)

      @blocks.each do |block|
        if block.is_a?(ElseBlock)
          return Luoma.render_block(block.block, context, buffer)
        else
          block.right.each do |expr|
            right = expr.evaluate(context)
            if (right.is_a?(PredicateFunction) && context.env.truthy?(right.call(context, left), context)) ||
               context.env.eq?(left, right, context, expr.span)
              return Luoma.render_block(block.block, context, buffer)
            end
          end
        end
      end
    end

    #: (RenderContext) -> Array[Markup]
    def children(static_context)
      @blocks
    end

    #: () -> Array[Expression]
    def expressions
      [@expression]
    end
  end

  class WhenBlock < Markup
    attr_reader :block, :right

    END_CASE_BLOCK = Set["endcase", "when", "else"]

    #: (String, Parser) -> WhenBlock
    def self.parse(tag_name, parser)
      parser.eat(:token_tag_start)
      parser.skip_whitespace_control
      token = parser.eat(:token_tag_name)

      right = [] #: Array[Expression]

      loop do
        expr = parser.parse_expression
        right << if parser.kind == :token_question &&
                    expr.is_a?(Variable) &&
                    expr.segments.empty? &&
                    expr.root.is_a?(Name)
                   parser.next
                   Predicate.new(expr.token, expr.root.value)
                 else
                   expr
                 end

        break unless parser.kind == :token_comma

        parser.next
      end

      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      block = parser.parse_block(stop: END_CASE_BLOCK)
      new(token, tag_name, right, block)
    end

    #: (t_token, String, Array[Expression], t_block) -> void
    def initialize(token, tag_name, right, block)
      super(token)
      @tag_name = tag_name
      @right = right
      @block = block
      @blank = Luoma.blank_block?(block)
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      Luoma.render_block(@block, context, buffer)
    end

    #: (RenderContext) -> Array[Markup]
    def children(static_context)
      @block.grep_v(String) #: Array[Markup]
    end

    #: () -> Array[Expression]
    def expressions
      @right
    end

    def filter_strings
      @block.filter! { |node| !node.is_a?(String) }
    end
  end
end
