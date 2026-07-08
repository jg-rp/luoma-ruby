# frozen_string_literal: true

module Luoma
  class ForTag < Markup
    END_FOR_BLOCK = Set["else", "endfor"]

    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      identifier = parser.parse_ident
      parser.eat(:token_in, message: "missing 'in'")
      parser.expect_expression
      expr = parser.parse_expression
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)

      block = parser.parse_block(stop: END_FOR_BLOCK)

      default = if parser.tag?("else")
                  parser.eat_empty_tag("else")
                  parser.parse_block(stop: END_FOR_BLOCK)
                end

      parser.eat_empty_tag("endfor")

      new(token, tag_name, identifier, expr, block, default)
    end

    #: (t_token, String, Name, Expression, t_block, t_block?) -> void
    def initialize(token, tag_name, identifier, expression, block, default)
      super(token)
      @tag_name = tag_name
      @identifier = identifier
      @expression = expression

      @blank = Luoma.blank_block?(block) && (!default || Luoma.blank_block?(default))

      @block = if @blank
                 block.grep_v(String)
               else
                 block
               end

      @default = if blank && default
                   default.grep_v(String)
                 else
                   default
                 end
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      array = context.env.to_a(@expression.evaluate(context), context)

      if array.empty? && @default
        Luoma.render_block(@default || raise, context, buffer)
        return
      end

      name = @identifier.value
      length = array.length

      for_loop_drop = ForLoopDrop.new(length, context.forloops.last)

      context.forloops << for_loop_drop
      namespace = { "forloop" => for_loop_drop } #: Hash[String, untyped]

      context.extends(namespace) do
        index = 0
        while index < length
          namespace[name] = array[index]
          for_loop_drop.next
          index += 1

          Luoma.render_block(@block, context, buffer)

          case context.interrupts.pop
          when :continue
            next
          when :break
            break
          end
        end
      ensure
        context.forloops.pop
      end
    end

    #: (RenderContext) -> Array[Markup]
    def children(static_context)
      result = @block.grep_v(String) #: Array[Markup]
      result.concat(@default.grep_v(String)) if @default # steep:ignore
      result
    end

    #: () -> Array[Expression]
    def expressions
      [@expression, @offset, @limit].compact
    end

    #: () -> Array[Name]
    def block_scope
      [@identifier]
    end
  end
end
