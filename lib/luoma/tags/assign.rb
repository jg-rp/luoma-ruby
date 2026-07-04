# frozen_string_literal: true

module Luoma
  class AssignTag < Markup
    #: (t_token, String, Parser) -> Markup
    def self.parse(token, tag_name, parser)
      identifier = parser.parse_ident
      parser.eat(:token_assign, message: "bad identifier or missing assignment operator")
      # TODO: multi assign
      expression = parser.parse_expression
      parser.carry_whitespace_control
      parser.eat(:token_tag_end)
      new(token, tag_name, identifier, expression)
    end

    #: (t_token, String, Name, Expression) -> void
    def initialize(token, tag_name, identifier, expression)
      super(token)
      @blank = true
      @tag_name = tag_name

      @identifier = identifier
      @expression = expression
    end

    #: (RenderContext, String) -> void
    def render(context, buffer)
      context.assign(@identifier.value, @expression.evaluate(context))
    end

    #: () -> Array[Expression]
    def expressions
      [@expression]
    end

    #: () -> Array[Name]
    def template_scope
      [@identifier]
    end
  end
end
