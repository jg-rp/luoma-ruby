# frozen_string_literal: true

require "test_helper"

class TestWhitespaceControl < Minitest::Test
  def test_no_whitespace_control
    source = <<~TEXT
      <ul>
      {% for x in (1..4) %}
        <li>{{ x }}</li>
      {% endfor %}
      </ul>
    TEXT

    expect = <<~TEXT
      <ul>\n
        <li>1</li>\n
        <li>2</li>\n
        <li>3</li>\n
        <li>4</li>\n
      </ul>
    TEXT

    assert_equal(expect, Luoma.render(source))
  end

  def test_tilde
    source = <<~TEXT
      <ul>
      {% for x in (1..4) ~%}
        <li>{{ x }}</li>
      {% endfor -%}
      </ul>
    TEXT

    expect = <<~TEXT
      <ul>
        <li>1</li>
        <li>2</li>
        <li>3</li>
        <li>4</li>
      </ul>
    TEXT

    assert_equal(expect, Luoma.render(source))
  end

  def test_auto_trim_tilde
    source = <<~TEXT
      <ul>
      {% for x in (1..4) %}
        <li>{{ x }}</li>
      {% endfor %}
      </ul>
    TEXT

    expect = <<~TEXT
      <ul>
        <li>1</li>
        <li>2</li>
        <li>3</li>
        <li>4</li>
      </ul>
    TEXT

    env = Luoma::Environment.new(auto_trim: "~")

    assert_equal(expect, env.render(source))
  end

  def test_auto_trim_hyphen
    source = <<~TEXT
      <ul>
      {% for x in (1..4) %}
        <li>{{ x }}</li>
      {% endfor %}
      </ul>
    TEXT

    expect = <<~TEXT
      <ul>
      <li>1</li>
      <li>2</li>
      <li>3</li>
      <li>4</li>
      </ul>
    TEXT

    env = Luoma::Environment.new(auto_trim: "-")

    assert_equal(expect, env.render(source))
  end

  def test_override_auto_trim
    source = <<~TEXT
      <ul>
      {% for x in (1..4) ~%}
        <li>{{ x }}</li>
      {% endfor %}
      </ul>
    TEXT

    expect = <<~TEXT
      <ul>
        <li>1</li>
        <li>2</li>
        <li>3</li>
        <li>4</li>
      </ul>
    TEXT

    env = Luoma::Environment.new(auto_trim: "-")

    assert_equal(expect, env.render(source))
  end

  def test_override_auto_trim_with_plus
    source = <<~TEXT
      <ul>
      {% for x in (1..4) +%}
        <li>{{ x }}</li>
      {% endfor +%}
      </ul>
    TEXT

    expect = <<~TEXT
      <ul>\n
        <li>1</li>\n
        <li>2</li>\n
        <li>3</li>\n
        <li>4</li>\n
      </ul>
    TEXT

    env = Luoma::Environment.new(auto_trim: "-")

    assert_equal(expect, env.render(source))
  end
end
