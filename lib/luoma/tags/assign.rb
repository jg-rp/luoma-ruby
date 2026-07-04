# frozen_string_literal: true

module Luoma
  class AssignTag < Markup
    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      bindings = [] #: Array[Item]

      name = parser.parse_ident
      assign_token = parser.eat(
        :token_assign,
        message: "bad identifier or missing assignment operator"
      )

      bindings << Item.new(assign_token, name, parser.parse_expression)

      until parser.kind != :token_comma
        parser.next
        name = parser.parse_ident
        assign_token = parser.eat(
          :token_assign,
          message: "bad identifier or missing assignment operator"
        )

        bindings << Item.new(assign_token, name, parser.parse_expression)
      end

      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      new(token, tag_name, bindings)
    end

    #: (t_token, String, Array[Item]) -> void
    def initialize(token, tag_name, bindings)
      super(token)
      @blank = true
      @tag_name = tag_name
      @bindings = bindings
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      @bindings.each do |binding|
        context.assign(binding.key.value, binding.expr.evaluate(context))
      end
    end

    #: () -> Array[Expression]
    def expressions
      @bindings.map(&:expr)
    end

    #: () -> Array[Name]
    def template_scope
      @bindings.map(&:key)
    end
  end
end
