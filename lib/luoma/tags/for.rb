# frozen_string_literal: true

module Luoma
  class ForTag < Markup
    END_FOR_BLOCK = Set["else", "endfor"]

    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      params = [parser.parse_ident] #: Array[Name]

      while parser.kind == :token_comma
        parser.next
        params << parser.parse_ident
      end

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

      new(token, tag_name, params, expr, block, default)
    end

    #: (t_token, String, Array[Name], Expression, t_block, t_block?) -> void
    def initialize(token, tag_name, params, expression, block, default)
      super(token)
      @tag_name = tag_name
      @params = params
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

      namespace = {} #: Hash[String, untyped]
      namespace[@params[2].value] = array if @params.length > 2

      name_param = @params.first.value
      index_param = @params[1].value if @params.length > 1
      length = array.length

      context.extends(namespace) do
        index = 0
        while index < length
          namespace[name_param] = array[index]
          namespace[index_param] = index if index_param
          index += 1

          Luoma.render_block(@block, context, buffer)

          case context.interrupts.pop
          when :continue
            next
          when :break
            break
          end
        end
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
      @params
    end
  end
end
