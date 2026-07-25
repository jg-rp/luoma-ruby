# frozen_string_literal: true

module Luoma
  class IfTag < Markup
    END_IF_BLOCK = Set["else", "elif", "elsif", "endif"]
    ELSE_IF_TAGS = Set["elif", "elsif"]

    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      blocks = [] #: Array[IfBlock | ElseBlock]
      parser.expect_expression
      expression = parser.parse_expression
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)

      block = parser.parse_block(stop: END_IF_BLOCK)
      blocks << IfBlock.new(token, "if", expression, block)

      loop do
        inner_tag_name = parser.tags(ELSE_IF_TAGS)
        break unless inner_tag_name

        blocks << IfBlock.parse(inner_tag_name, parser)
      end

      if parser.tag?("else")
        name_token = parser.eat_empty_tag("else")
        blocks << ElseBlock.new(
          name_token,
          "else",
          parser.parse_block(stop: END_IF_BLOCK)
        )
      end

      parser.eat_empty_tag("endif")
      IfTag.new(token, tag_name, blocks)
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
        if context.env.truthy?(alt.expression.evaluate(context), context)
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

  class IfBlock < Markup
    attr_reader :expression, :block

    END_IF_BLOCK = Set["else", "elsif", "elif", "endif", "endunless"]

    #: (Parser) -> Markup
    def self.parse(tag_name, parser)
      parser.eat(:token_tag_start)
      parser.skip_whitespace_control
      token = parser.eat(:token_tag_name)
      parser.expect_expression
      expression = parser.parse_expression
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      IfBlock.new(token, tag_name, expression, parser.parse_block(stop: END_IF_BLOCK))
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
