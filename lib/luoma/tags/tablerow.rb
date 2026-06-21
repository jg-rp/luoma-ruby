# frozen_string_literal: true

module Luoma
  class TableRowTag < Markup
    END_TABLEROW_BLOCK = Set["endtablerow"]

    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      ident = parser.parse_ident
      parser.eat(:token_in, message: "missing 'in'")
      parser.expect_expression
      expr = parser.parse_expression

      # Leading commas are OK.
      parser.next if parser.kind == :token_comma

      cols, offset, limit = unpack_args(parser.parse_keyword_arguments, parser)
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      block = parser.parse_block(stop: END_TABLEROW_BLOCK)
      parser.eat_empty_tag("endtablerow")

      new(token, tag_name, ident, expr, block, cols, offset, limit)
    end

    #: (Array[KeywordArgument], Parser) -> [Expression?, Expression?, Expression?]
    def self.unpack_args(args, parser)
      cols = nil #: Expression?
      offset = nil #: Expression?
      limit = nil #: Expression?

      args.each do |arg|
        case arg
        in KeywordArgument("cols", expr)
          cols = expr
        in KeywordArgument("offset", expr)
          offset = expr
        in KeywordArgument("limit", expr)
          limit = expr
        else
          raise TemplateSyntaxError.new(
            "unexpected argument",
            arg.span,
            parser.source,
            parser.template_name
          )
        end
      end

      [cols, offset, limit]
    end

    #: (t_token,
    #   String,
    #   Name,
    #   Expression,
    #   t_block,
    #   Expression?,
    #   Expression?,
    #   Expression?,
    #  ) -> void
    def initialize(
      token,
      tag_name,
      identifier,
      expression,
      block,
      cols,
      offset,
      limit
    )
      super(token)
      @tag_name = tag_name
      @identifier = identifier
      @expression = expression
      @block = block
      @cols = cols
      @offset = offset
      @limit = limit
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      name = @identifier.value

      array = context.env.to_a(
        @expression.evaluate(context),
        context,
        @expression.span
      )

      cols = context.env.to_i(
        @cols&.evaluate(context) || array.length,
        context,
        @cols&.span || @token,
        default: array.length
      )

      offset = context.env.to_i(
        @offset&.evaluate(context) || 0,
        context,
        @offset&.span || @token,
        default: 0
      )

      limit = context.env.to_i(
        @limit&.evaluate(context) || array.length,
        context,
        @limit&.span || @token,
        default: array.length
      )

      array_ = array.slice(offset, limit) || []
      tablerowloop = TableRowLoopDrop.new(array_.length, cols)
      namespace = { "tablerowloop" => tablerowloop }

      context.extends(namespace) do
        buffer << "<tr class=\"row1\">\n"
        index = 0
        while index < array_.length
          namespace[name] = array_[index]
          index += 1

          buffer << "<td class=\"col#{tablerowloop.col}\">"
          Luoma.render_block(@block, context, buffer)
          buffer << "</td>"

          break if context.interrupts.pop == :break

          buffer << "</tr>\n<tr class=\"row#{tablerowloop.row + 1}\">" if tablerowloop.col_last && !tablerowloop.last
          tablerowloop.next
        end

        buffer << "</tr>\n"
      end
    end

    #: (RenderContext) -> Array[Markup]
    def children(static_context)
      @block.grep_v(String) #: Array[Markup]
    end

    #: () -> Array[Expression]
    def expressions
      [@expression, @cols, @offset, @limit].compact
    end

    #: () -> Array[Name]
    def block_scope
      [@ident]
    end
  end
end
