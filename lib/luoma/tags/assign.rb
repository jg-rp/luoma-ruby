# frozen_string_literal: true

module Luoma
  class AssignTag < Markup
    #: (t_token, Parser) -> Markup
    def self.parse(token, parser)
      name = parser.parse_ident
      parser.eat(:token_assign, message: "bad identifier or missing assignment operator")
      expression = parser.parse_filtered_expression
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      new(token, name, expression)
    end

    #: (t_token, Name, Expression) -> void
    def initialize(token, name, expression)
      super(token)
      @blank = true
      @tag = "assign"

      @name = name
      @expression = expression
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      context.assign(@name.value, @expression.evaluate(context))
    end

    #: () -> Array[Expression]
    def expressions
      [@expression]
    end

    #: () -> Array[Name]
    def template_scope
      [@name]
    end
  end
end
