# frozen_string_literal: true

require "test_helper"

class TestFontRenderingExample < Minitest::Spec
  make_my_diffs_pretty!

  module Mock
    DATA = {
      "settings" => {
        "type_body_font" => {
          "family" => "Roboto",
          "style" => "normal",
          "weight" => "400"
        },
        "type_subheading_font" => {
          "family" => "Arial",
          "style" => "normal",
          "weight" => "400"
        },
        "type_heading_font" => {
          "family" => "Arial",
          "style" => "normal",
          "weight" => "400"
        },
        "type_accent_font" => {
          "family" => "Arial",
          "style" => "normal",
          "weight" => "400"
        }
      }
    }.freeze

    def self.font_modify(context, left, prop, value)
      return left unless left.is_a?(Hash)

      left_ = left.dup

      case prop
      when "family"
        left_["family"] = context.to_string(value)
      when "style"
        left_["style"] = context.to_string(value)
      when "weight"
        left_["weight"] = context.to_string(value)
      end

      left_
    end

    def self.font_face(context, left, font_display: nil)
      return "" unless left.is_a?(Hash)

      fields = [
        "  font-family: #{left["family"]};",
        "  font-style: #{left["style"]};",
        "  font-weight: #{left["weight"]};"
      ]

      fields << "  font-display: #{font_display};" if font_display.is_a?(String)

      "@font-face {\n#{fields.join("\n")}\n}"
    end
  end

  def test_example
    loader = Luoma::HashLoader.new(
      { "font_utils" => <<~SOURCE
        {% assign
          bold        = f -> (f | font_modify: 'weight', 'bold'),
          italic      = f -> (f | font_modify: 'style', 'italic'),
          bold_italic = f -> (f | font_modify: 'weight', 'bold' | font_modify: 'style', 'italic')
        %}
      SOURCE
     }
    )

    env = Luoma::Environment.new(
      loader: loader
    )

    env.filters["font_modify"] = Mock.method(:font_modify)
    env.filters["font_face"] = Mock.method(:font_face)

    source = <<~SOURCE
      {%- import "font_utils" -%}

      {% with
        font_types = [
          settings.type_body_font,
          settings.type_subheading_font,
          settings.type_heading_font,
          settings.type_accent_font
        ],

        font_faces = font_types
          | flat_map : f -> [f, (f | bold), (f | italic), (f | bold_italic)]
          | uniq     : f -> '${f.family}-${f.weight}-${f.style}'
          | map      : f -> (f | font_face: font_display: 'swap')
      %}
        {{- font_faces | join: "\n\n" -}}
      {% endwith %}
    SOURCE

    template = env.parse(source)

    assert_equal(<<~WANT, template.render(Mock::DATA))
      @font-face {
        font-family: Roboto;
        font-style: normal;
        font-weight: 400;
        font-display: swap;
      }

      @font-face {
        font-family: Roboto;
        font-style: normal;
        font-weight: bold;
        font-display: swap;
      }

      @font-face {
        font-family: Roboto;
        font-style: italic;
        font-weight: 400;
        font-display: swap;
      }

      @font-face {
        font-family: Roboto;
        font-style: italic;
        font-weight: bold;
        font-display: swap;
      }

      @font-face {
        font-family: Arial;
        font-style: normal;
        font-weight: 400;
        font-display: swap;
      }

      @font-face {
        font-family: Arial;
        font-style: normal;
        font-weight: bold;
        font-display: swap;
      }

      @font-face {
        font-family: Arial;
        font-style: italic;
        font-weight: 400;
        font-display: swap;
      }

      @font-face {
        font-family: Arial;
        font-style: italic;
        font-weight: bold;
        font-display: swap;
      }
    WANT
  end
end
