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

      # Leading commas are OK.
      parser.eat(:token_comma) if parser.kind == :token_comma

      offset, limit, reversed = unpack_args(
        parser.parse_arguments(require_commas: false), parser
      )

      parser.carry_whitespace_control
      parser.eat(:token_tag_end)

      block = parser.parse_block(stop: END_FOR_BLOCK)

      default = if parser.tag?("else")
                  parser.eat_empty_tag("else")
                  parser.parse_block(stop: END_FOR_BLOCK)
                end

      parser.eat_empty_tag("endfor")

      new(token, tag_name, identifier, expr, block, default, offset, limit, reversed)
    end

    #: (Array[Expression|KeywordArgument], Parser) -> [Expression?, Expression?, bool]
    def self.unpack_args(args, parser)
      offset = nil #: Expression?
      limit = nil #: Expression?
      reversed = false

      args.each do |arg|
        case arg
        in KeywordArgument("offset", expr)
          offset = expr
        in KeywordArgument("limit", expr)
          limit = expr
        in KeywordArgument(name, expr)
          raise TemplateSyntaxError.new(
            "unexpected argument #{name}",
            arg.span,
            parser.source,
            parser.template_name
          )
        else
          if arg.is_a?(Variable) &&
             arg.root.is_a?(Name) &&
             arg.root.value == "reversed" &&
             arg.segments.empty?
            reversed = true
          else
            raise TemplateSyntaxError.new(
              "unexpected argument",
              arg.span,
              parser.source,
              parser.template_name
            )
          end
        end
      end

      [offset, limit, reversed]
    end

    #: (t_token,
    #   String,
    #   Name,
    #   Expression,
    #   t_block,
    #   t_block?,
    #   Expression?,
    #   Expression?,
    #   bool
    #  ) -> void
    def initialize(
      token,
      tag_name,
      identifier,
      expression,
      block,
      default,
      offset,
      limit,
      reversed
    )
      super(token)
      @tag_name = tag_name
      @identifier = identifier
      @expression = expression
      @block = block
      @offset = offset
      @limit = limit
      @reversed = reversed

      @blank = Luoma.blank_block?(block) && (!default || Luoma.blank_block?(default))

      @default = if blank && default
                   default.grep_v(String)
                 else
                   default
                 end

      @offset_key = "#{identifier.value}-#{expression}"
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      target = @expression.evaluate(context)

      raise "TODO:" if target.is_a?(Drop)

      array = slice(
        context.env.to_a(target, context, @expression.span),
        @offset.is_a?(Variable) && @offset.ident?("continue") ? :continue : @offset&.evaluate(context), # steep:ignore
        @limit&.evaluate(context),
        context
      )

      if array.empty? && @default
        Luoma.render_block(@default || raise, context, buffer)
        return
      end

      name = @identifier.value
      length = array.length

      for_loop_drop = ForLoopDrop.new(
        "#{name}-#{@expression}",
        length,
        context.forloops.last
      )

      context.forloops << for_loop_drop
      namespace = { "forloop" => for_loop_drop } #: Hash[String, untyped]

      context.extends(namespace) do
        index = 0
        while index < length
          namespace[name] = array[index]
          index += 1
          for_loop_drop.next
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

    #: (Array[untyped], untyped, untyped, RenderContext) -> Array[untyped]
    def slice(array, offset, limit, context)
      offset_ = if offset == :continue
                  context.registers[:for][@offset_key]
                else
                  context.env.nothing?(offset) ? 0 : context.env.to_i(offset, context, @offset&.span || @token)
                end

      limit_ = context.env.nothing?(limit) ? array.length : context.env.to_i(limit, context, @limit&.span || @token)

      array_ = array.slice(offset_, limit_) || []
      @reversed ? array_.reverse! : array_
    end
  end
end
