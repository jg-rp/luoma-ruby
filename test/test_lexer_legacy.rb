# frozen_string_literal: true

require "test_helper"

#: (String) -> Array[[String, String]]
def tokenize(source)
  Luoma::LegacyLexer
    .tokenize(Luoma::Environment.new, source)
    .map { |t| [Luoma::TOKEN_KIND_MAP[t.first], Luoma.get_token_value(t, source)] }
end

class TestLexerLegacy < Minitest::Test
  def test_tokenize_empty
    assert_equal(tokenize(""), [])
  end

  def test_tokenize_just_text
    assert_equal(tokenize("Hello, World!"), [["TEXT", "Hello, World!"]])
  end

  def test_tokenize_just_output
    assert_equal(
      tokenize("{{ hello }}"),
      [
        ["OUT_START", "{{"],
        ["IDENT", "hello"],
        ["OUT_END", "}}"]
      ]
    )
  end

  def test_tokenize_hello_you
    assert_equal(
      tokenize("Hello, {{ you }}!"),
      [
        ["TEXT", "Hello, "],
        ["OUT_START", "{{"],
        ["IDENT", "you"],
        ["OUT_END", "}}"],
        ["TEXT", "!"]
      ]
    )
  end

  def test_tokenize_whitespace_control
    assert_equal(
      tokenize("Hello, {{- you -}}!"),
      [
        ["TEXT", "Hello, "],
        ["OUT_START", "{{"],
        ["WC", "-"],
        ["IDENT", "you"],
        ["WC", "-"],
        ["OUT_END", "}}"],
        ["TEXT", "!"]
      ]
    )
  end

  def test_tokenize_single_quoted_string_literal
    assert_equal(
      tokenize("{{ 'Hello, World!' }}"),
      [
        ["OUT_START", "{{"],
        ["SINGLE_QUOTE", "'"],
        ["SINGLE_QUOTED", "Hello, World!"],
        ["SINGLE_QUOTE", "'"],
        ["OUT_END", "}}"]
      ]
    )
  end

  def test_tokenize_double_quoted_string_literal
    assert_equal(
      tokenize('{{ "Hello, World!" }}'),
      [
        ["OUT_START", "{{"],
        ["DOUBLE_QUOTE", '"'],
        ["DOUBLE_QUOTED", "Hello, World!"],
        ["DOUBLE_QUOTE", '"'],
        ["OUT_END", "}}"]
      ]
    )
  end

  def test_tokenize_filter
    assert_equal(
      tokenize("{{ 42 | plus: 3 }}"),
      [
        ["OUT_START", "{{"],
        ["INT", "42"],
        ["PIPE", "|"],
        ["IDENT", "plus"],
        ["COLON", ":"],
        ["INT", "3"],
        ["OUT_END", "}}"]
      ]
    )
  end

  def test_tokenize_float_literal
    assert_equal(
      tokenize("{{ 42.2 | plus: 3.0 }}"),
      [
        ["OUT_START", "{{"],
        ["FLOAT", "42.2"],
        ["PIPE", "|"],
        ["IDENT", "plus"],
        ["COLON", ":"],
        ["FLOAT", "3.0"],
        ["OUT_END", "}}"]
      ]
    )
  end

  def test_tokenize_range_literal
    assert_equal(
      tokenize("{{ (1..5) | join: ', ' }}"),
      [
        ["OUT_START", "{{"],
        ["LPAREN", "("],
        ["INT", "1"],
        ["DOUBLE_DOT", ".."],
        ["INT", "5"],
        ["RPAREN", ")"],
        ["PIPE", "|"],
        ["IDENT", "join"],
        ["COLON", ":"],
        ["SINGLE_QUOTE", "'"],
        ["SINGLE_QUOTED", ", "],
        ["SINGLE_QUOTE", "'"],
        ["OUT_END", "}}"]
      ]
    )
  end

  def test_tokenize_ident_with_trailing_question_mark
    assert_equal(
      tokenize("{{ eh? }}"),
      [
        ["OUT_START", "{{"],
        ["IDENT", "eh?"],
        ["OUT_END", "}}"]
      ]
    )
  end

  def test_tokenize_raw
    assert_equal(
      tokenize("Hello, {% raw %}{{ you }}{% endraw %}"),
      [
        ["TEXT", "Hello, "],
        ["TAG_START", "{%"],
        ["TAG_NAME", "raw"],
        ["TAG_END", "%}"],
        ["TEXT", "{{ you }}"],
        ["TAG_START", "{%"],
        ["TAG_NAME", "endraw"],
        ["TAG_END", "%}"]
      ]
    )
  end

  def test_tokenize_raw_wc
    assert_equal(
      tokenize("Hello, {%- raw -%}{{ you }}{%- endraw -%}!"),
      [
        ["TEXT", "Hello, "],
        ["TAG_START", "{%"],
        ["WC", "-"],
        ["TAG_NAME", "raw"],
        ["WC", "-"],
        ["TAG_END", "%}"],
        ["TEXT", "{{ you }}"],
        ["TAG_START", "{%"],
        ["WC", "-"],
        ["TAG_NAME", "endraw"],
        ["WC", "-"],
        ["TAG_END", "%}"],
        ["TEXT", "!"]
      ]
    )
  end

  def test_tokenize_tag
    assert_equal(
      tokenize("{% assign x = true %}"),
      [
        ["TAG_START", "{%"],
        ["TAG_NAME", "assign"],
        ["IDENT", "x"],
        ["ASSIGN", "="],
        ["TRUE", "true"],
        ["TAG_END", "%}"]
      ]
    )
  end

  def test_tokenize_single_closing_brace
    assert_equal(
      tokenize("{{.} "),
      [
        ["OUT_START", "{{"],
        ["DOT", "."],
        ["OUT_END", "}"],
        ["TEXT", " "]
      ]
    )
  end

  def test_tokenize_extra_closing_brace
    assert_equal(
      tokenize("{{}}}"),
      [
        ["OUT_START", "{{"],
        ["OUT_END", "}}"],
        ["TEXT", "}"]
      ]
    )
  end

  def test_tokenize_single_closing_brace_then_closing_tag
    assert_equal(
      tokenize("{{}%}"),
      [
        ["OUT_START", "{{"],
        ["OUT_END", "}"],
        ["TEXT", "%}"]
      ]
    )
  end

  def test_tokenize_close_output_with_tag_delim
    assert_equal(
      tokenize("{{%}"),
      [
        ["OUT_START", "{{"],
        ["OUT_END", "%}"]
      ]
    )
  end

  def test_tokenize_output_percents
    assert_equal(
      tokenize("{{%%%}}"),
      [
        ["OUT_START", "{{"],
        ["UNKNOWN", "%"],
        ["UNKNOWN", "%"],
        ["UNKNOWN", "%"],
        ["OUT_END", "}}"]
      ]
    )
  end

  def test_tokenize_open_tag_close_output
    assert_equal(
      tokenize("{%}}"),
      [
        ["TEXT", "{%}}"]
      ]
    )
  end

  def test_tokenize_tag_followed_by_brace
    assert_equal(
      tokenize("{%%}}"),
      [
        ["TAG_START", "{%"],
        ["TAG_END", "%}"],
        ["TEXT", "}"]
      ]
    )
  end
end
