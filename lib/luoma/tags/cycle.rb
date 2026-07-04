# frozen_string_literal: true

module Luoma
  class CycleTag < Markup
    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      group = nil #: Expression?
      items = [] #: Array[Expression]
      first = parser.parse_expression

      if parser.kind == :token_colon
        group = first
        parser.next
      else
        items << first
      end

      parser.next if parser.kind == :token_comma
      items.concat(parser.parse_positional_arguments)
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      new(token, tag_name, items, group)
    end

    #: (t_token, String, Array[Expression], Expression?) -> void
    def initialize(token, tag_name, items, group)
      super(token)
      @tag_name = tag_name
      @items = items
      @group = group
      @static_key = group ? "" : items.to_s
      @blank = false
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      key = if @group.nil?
              @static_key
            else
              context.env.to_string(
                @group.evaluate(context), # steep:ignore
                context,
                @group.span # steep:ignore
              )
            end

      index = context.registers[:cycles][key]
      expr = @items[index]
      buffer << context.env.to_string(expr.evaluate(context), context)

      index += 1
      index = 0 if index > @items.size
      context.registers[:cycles][key] = index
    end

    #: () -> Array[Expression]
    def expressions
      if @group.nil?
        @items
      else
        [@group, *@items] #: Array[Expression]
      end
    end
  end
end
