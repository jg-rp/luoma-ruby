# frozen_string_literal: true

module Luoma
  class CaseTag < Markup
    END_CASE_BLOCK = Set["endcase", "when", "else"]
    CASE_BLOCKS = Set["when", "else"]

    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      parser.expect_expression
      expression = parser.parse_expression
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)

      # Junk between `{% case %}` and first `{% when %}`.
      parser.eat(:token_text) if parser.kind == :token_text

      blocks = [] #: Array[WhenBlock|ElseBlock]

      loop do
        case parser.tags(CASE_BLOCKS)
        when "when"
          blocks << WhenBlock.parse("when", parser)
        when "else"
          else_token = parser.eat_tag("else")
          blocks << ElseBlock.new(else_token, "else", parser.parse_block(stop: END_CASE_BLOCK))
        else
          break
        end
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
      raise "TODO:"
    end

    #: (RenderContext) -> Array[Markup]
    def children(static_context)
      raise "TODO:"
    end

    #: () -> Array[Expression]
    def expressions
      [@expression]
    end
  end

  class WhenBlock < Markup
    END_CASE_BLOCK = Set["endcase", "when", "else"]
    WHEN_DELIMITERS = Set[:token_comma, :token_or] #: Set[t_token_kind]

    #: (String, Parser) -> WhenBlock
    def self.parse(tag_name, parser)
      parser.eat(:token_tag_start)
      parser.skip_whitespace_control
      token = parser.eat(:token_tag_name)

      # Leading commas are OK
      parser.next if parser.kind == :token_comma

      right = [] #: Array[Expression]

      loop do
        right << parser.parse_expression(infix: false)
        break unless WHEN_DELIMITERS.include?(parser.kind)

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
      @block.filter { |node| !node.is_a?(String) } #: Array[Markup]
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
