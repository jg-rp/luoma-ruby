# frozen_string_literal: true

module Luoma
  class UnlessTag < Markup
    END_UNLESS_BLOCK = Set["else", "elsif", "endunless"]
    UNLESS_BLOCKS = Set["else", "elsif"]

    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      blocks = [] #: Array[UnlessBlock | IfBlock | ElseBlock]
      parser.expect_expression
      expression = parser.parse_expression
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)

      block = parser.parse_block(stop: END_UNLESS_BLOCK)
      blocks << UnlessBlock.new(token, "unless", expression, block)

      loop do
        case parser.tags(UNLESS_BLOCKS)
        when "elsif"
          blocks << IfBlock.parse("elsif", parser)
        when "else"
          # Any remaining `else` or `elsif` blocks are guaranteed to be
          # ignored, but we keep them in the AST anyway.
          name_token = parser.eat_tag("else")
          blocks << ElseBlock.new(
            name_token,
            "else",
            parser.parse_block(stop: END_UNLESS_BLOCK)
          )
        else
          break
        end
      end

      parser.eat_empty_tag("endunless")
      UnlessTag.new(token, tag_name, blocks)
    end

    def initialize(token, tag_name, alts)
      super(token)
      @tag_name = tag_name
      @alts = alts
      @blank = alts.all?(&:blank)
      @alts.each(&:filter_strings) if @blank
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      index = 0
      while (alt = @alts[index])
        if alt.is_a?(UnlessBlock)
          unless context.env.truthy?(alt.expression.evaluate(context), context)
            Luoma.render_block(alt.block, context, buffer)
            break
          end
        elsif context.env.truthy?(alt.expression.evaluate(context), context)
          Luoma.render_block(alt.block, context, buffer)
          break
        end
        index += 1
      end
    end

    #: (RenderContext) -> Array[Markup]
    def children(static_context)
      @alts
    end
  end

  class UnlessBlock < Markup
    attr_reader :expression, :block

    END_UNLESS_BLOCK = Set["else", "elsif", "endunless"]

    #: (Parser) -> Markup
    def self.parse(tag_name, parser)
      parser.eat(:token_tag_start)
      parser.skip_whitespace_control
      token = parser.eat(:token_tag_name)
      parser.expect_expression
      expression = parser.parse_expression
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      UnlessBlock.new(token, tag_name, expression, parser.parse_block(stop: END_UNLESS_BLOCK))
    end

    def initialize(token, tag_name, expression, block)
      super(token)
      @tag_name = tag_name
      @expression = expression
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
      [@expression]
    end

    def filter_strings
      @block.filter! { |node| !node.is_a?(String) }
    end
  end
end
