# frozen_string_literal: true

require "test_helper"

class TestRenderDrops < Minitest::Test
  def test_render_block_drop
    source = <<~SOURCE
      {%- define x -%}
        Hello,{{ you }}!
      {%- enddefine -%}
      {{ x }}
      {% with you = ' world' -%}
        {{ x }}
      {% endwith -%}
      {{ x -}}
    SOURCE

    want = <<~TEXT.chomp
      Hello,!
      Hello, world!
      Hello,!
    TEXT

    assert_equal(want, Luoma.render(source))
  end

  def test_render_array_of_blocks
    source = <<~SOURCE
      {%- define x -%}
        Hello,{{ you }}!
      {%- enddefine -%}

      {%- define y -%}
        {{ 42 + z }}
      {%- enddefine -%}

      {% with
        blocks = [x, y],
        you = ' world',
        z = 8,
      -%}
        {{ blocks }}
      {%- endwith -%}
    SOURCE

    want = <<~TEXT.chomp
      Hello, world!
      50
    TEXT

    assert_equal(want, Luoma.render(source))
  end

  def test_render_array_of_blocks_and_strings
    source = <<~SOURCE
      {%- define x -%}
        Hello,{{ you }}!
      {%- enddefine -%}

      {%- define y -%}
        {{ 42 + z }}
      {%- enddefine -%}

      {% with
        blocks = [x, '\\n\\n', y],
        you = ' world',
        z = 8,
      -%}
        {{ blocks }}
      {%- endwith -%}
    SOURCE

    want = <<~TEXT.chomp
      Hello, world!

      50
    TEXT

    assert_equal(want, Luoma.render(source))
  end
end
