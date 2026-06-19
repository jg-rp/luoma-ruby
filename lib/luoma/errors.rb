# frozen_string_literal: true

module Luoma
  # The base class for all template errors.
  class LuomaError < StandardError
  end

  class DetailedLuomaError < LuomaError
    attr_accessor :token, :template_name, :source

    def initialize(message, token, source, template_name)
      super(message)
      @token = token
      @source = source
      @template_name = template_name
    end

    def detailed_message(highlight: true, **kwargs)
      value = Luoma.get_token_value(@token, @source)
      line, col, current_line = error_context(@source, @token[1])

      name_and_position = if @template_name.empty?
                            "#{current_line.inspect}:#{line}:#{col}"
                          else
                            "#{@template_name}:#{line}:#{col}"
                          end

      pad = " " * line.to_s.length
      pointer = (" " * (col - 1)) + ("^" * (value&.length || 1))

      <<~MESSAGE.strip
        #{self.class}: #{message}
        #{pad} -> #{name_and_position}
        #{pad} |
        #{line} | #{current_line}
        #{pad} | #{pointer} #{highlight ? "\e[1m#{message}\e[0m" : message}
      MESSAGE
    end

    protected

    def error_context(source, index)
      lines = source.lines
      cumulative_length = 0
      target_line_index = -1

      lines.each_with_index do |line, i|
        cumulative_length += line.length
        next unless index < cumulative_length

        target_line_index = i
        line_number = target_line_index + 1
        column_number = index - (cumulative_length - lines[target_line_index].length) + 1
        return [line_number, column_number, lines[target_line_index].rstrip]
      end

      raise "index is out of bounds for span"
    end
  end

  class DisabledTagError < DetailedLuomaError; end
  class FilterArgumentError < DetailedLuomaError; end
  class FilterNotFoundError < DetailedLuomaError; end
  class TemplateInheritanceError < DetailedLuomaError; end
  class RequiredBlockError < TemplateInheritanceError; end
  class ResourceLimitError < LuomaError; end
  class ContextDepthError < ResourceLimitError; end
  class TemplateNotFoundError < LuomaError; end
  class NoSuchTemplateError < DetailedLuomaError; end
  class TemplateSyntaxError < DetailedLuomaError; end
  class TemplateTypeError < DetailedLuomaError; end
  class UndefinedVariableError < DetailedLuomaError; end
end
