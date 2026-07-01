# frozen_string_literal: true

require "test_helper"

#: (String) -> Array[[String, String]]
def tokenize(source)
  Luoma::UnifiedLexer
    .tokenize(Luoma::Environment.new, source)
    .map { |t| [Luoma::TOKEN_KIND_MAP[t.first], Luoma.get_token_value(t, source)] }
end

class TestUnifiedLexer < Minitest::Test
  def test_empty
    assert_equal([], tokenize(""))
  end

  def test_no_markup
    assert_equal([["TEXT", "Hello, World!"]], tokenize("Hello, World!"))
  end

  def test_just_whitespace
    assert_equal([["TEXT", "\n   "]], tokenize("\n   "))
  end

  def test_just_output
    assert_equal([
                   ["OUT_START", "{{"],
                   ["IDENT", "hello"],
                   ["OUT_END", "}}"]
                 ], tokenize("{{ hello }}"))
  end

  def test_hello_world
    assert_equal([
                   ["TEXT", "Hello, "],
                   ["OUT_START", "{{"],
                   ["IDENT", "you"],
                   ["OUT_END", "}}"],
                   ["TEXT", "!"]
                 ], tokenize("Hello, {{ you }}!"))
  end

  def test_filter_with_argument
    assert_equal([
                   ["OUT_START", "{{"],
                   ["INT", "42"],
                   ["PIPE", "|"],
                   ["IDENT", "plus"],
                   ["COLON", ":"],
                   ["INT", "3"],
                   ["OUT_END", "}}"]
                 ], tokenize("{{ 42 | plus: 3 }}"))
  end

  def test_range_literal
    assert_equal([
                   ["OUT_START", "{{"],
                   ["LPAREN", "("],
                   ["INT", "1"],
                   ["DOUBLE_DOT", ".."],
                   ["INT", "5"],
                   ["RPAREN", ")"],
                   ["OUT_END", "}}"]
                 ], tokenize("{{ (1..5) }}"))
  end

  def test_single_quoted_string
    assert_equal([
                   ["OUT_START", "{{"],
                   ["SINGLE_QUOTE", "'"],
                   ["SINGLE_QUOTED", "hello"],
                   ["SINGLE_QUOTE", "'"],
                   ["OUT_END", "}}"]
                 ], tokenize("{{ 'hello' }}"))
  end

  def test_double_quoted_string
    assert_equal([
                   ["OUT_START", "{{"],
                   ["DOUBLE_QUOTE", '"'],
                   ["DOUBLE_QUOTED", "hello"],
                   ["DOUBLE_QUOTE", '"'],
                   ["OUT_END", "}}"]
                 ], tokenize('{{ "hello" }}'))
  end

  def test_empty_string
    assert_equal([
                   ["OUT_START", "{{"],
                   ["DOUBLE_QUOTE", '"'],
                   ["DOUBLE_QUOTE", '"'],
                   ["OUT_END", "}}"]
                 ], tokenize('{{ "" }}'))
  end

  def test_single_quoted_escaped_segment
    assert_equal([
                   ["OUT_START", "{{"],
                   ["SINGLE_QUOTE", "'"],
                   ["SINGLE_QUOTED", "hello"],
                   ["SINGLE_ESCAPED", "\\r\\nworld"],
                   ["SINGLE_QUOTE", "'"],
                   ["OUT_END", "}}"]
                 ], tokenize("{{ 'hello\\r\\nworld' }}"))
  end

  def test_single_quoted_trailing_escaped_segment
    assert_equal([
                   ["OUT_START", "{{"],
                   ["SINGLE_QUOTE", "'"],
                   ["SINGLE_QUOTED", "hello"],
                   ["SINGLE_ESCAPED", "\\r\\n"],
                   ["SINGLE_QUOTE", "'"],
                   ["OUT_END", "}}"]
                 ], tokenize("{{ 'hello\\r\\n' }}"))
  end

  def test_single_quoted_leading_escaped_segment
    assert_equal([
                   ["OUT_START", "{{"],
                   ["SINGLE_QUOTE", "'"],
                   ["SINGLE_ESCAPED", "\\r\\nhello"],
                   ["SINGLE_QUOTE", "'"],
                   ["OUT_END", "}}"]
                 ], tokenize("{{ '\\r\\nhello' }}"))
  end

  def test_single_quoted_expression_segment
    assert_equal([
                   ["OUT_START", "{{"],
                   ["SINGLE_QUOTE", "'"],
                   ["SINGLE_QUOTED", "hello "],
                   ["INTERPOLATION_START", "${"],
                   ["IDENT", "you"],
                   ["INTERPOLATION_END", "}"],
                   ["SINGLE_QUOTED", "!"],
                   ["SINGLE_QUOTE", "'"],
                   ["OUT_END", "}}"]
                 ], tokenize("{{ 'hello ${you}!' }}"))
  end

  def test_single_quoted_trailing_expression_segment
    assert_equal([
                   ["OUT_START", "{{"],
                   ["SINGLE_QUOTE", "'"],
                   ["SINGLE_QUOTED", "hello "],
                   ["INTERPOLATION_START", "${"],
                   ["IDENT", "you"],
                   ["INTERPOLATION_END", "}"],
                   ["SINGLE_QUOTE", "'"],
                   ["OUT_END", "}}"]
                 ], tokenize("{{ 'hello ${you}' }}"))
  end

  def test_single_quoted_leading_expression_segment
    assert_equal([
                   ["OUT_START", "{{"],
                   ["SINGLE_QUOTE", "'"],
                   ["INTERPOLATION_START", "${"],
                   ["IDENT", "you"],
                   ["INTERPOLATION_END", "}"],
                   ["SINGLE_QUOTED", " hello"],
                   ["SINGLE_QUOTE", "'"],
                   ["OUT_END", "}}"]
                 ], tokenize("{{ '${you} hello' }}"))
  end

  def test_single_quoted_expression_followed_by_escaped
    assert_equal([
                   ["OUT_START", "{{"],
                   ["SINGLE_QUOTE", "'"],
                   ["INTERPOLATION_START", "${"],
                   ["IDENT", "you"],
                   ["INTERPOLATION_END", "}"],
                   ["SINGLE_ESCAPED", "\\nhello"],
                   ["SINGLE_QUOTE", "'"],
                   ["OUT_END", "}}"]
                 ], tokenize("{{ '${you}\\nhello' }}"))
  end

  def test_tag
    assert_equal([
                   ["TAG_START", "{%"],
                   ["TAG_NAME", "foo"],
                   ["TAG_END", "%}"]
                 ], tokenize("{% foo %}"))
  end

  def test_tag_expression
    assert_equal([
                   ["TAG_START", "{%"],
                   ["TAG_NAME", "foo"],
                   ["IDENT", "x"],
                   ["IF", "if"],
                   ["IDENT", "y"],
                   ["ELSE", "else"],
                   ["IDENT", "z"],
                   ["TAG_END", "%}"]
                 ], tokenize("{% foo x if y else z %}"))
  end

  def test_tag_whitespace_control
    assert_equal([
                   ["TAG_START", "{%"],
                   ["WC", "+"],
                   ["TAG_NAME", "foo"],
                   ["WC", "-"],
                   ["TAG_END", "%}"]
                 ], tokenize("{%+ foo -%}"))
  end

  def test_raw_empty
    assert_equal([
                   ["TAG_START", "{%"],
                   ["TAG_NAME", "raw"],
                   ["TAG_END", "%}"],
                   ["TAG_START", "{%"],
                   ["TAG_NAME", "endraw"],
                   ["TAG_END", "%}"]
                 ], tokenize("{% raw %}{% endraw %}"))
  end

  def test_raw
    assert_equal([
                   ["TAG_START", "{%"],
                   ["TAG_NAME", "raw"],
                   ["TAG_END", "%}"],
                   ["TEXT", "{{ hello }}"],
                   ["TAG_START", "{%"],
                   ["TAG_NAME", "endraw"],
                   ["TAG_END", "%}"]
                 ], tokenize("{% raw %}{{ hello }}{% endraw %}"))
  end

  def test_raw_whitespace_control
    assert_equal([
                   ["TAG_START", "{%"],
                   ["WC", "-"],
                   ["TAG_NAME", "raw"],
                   ["WC", "+"],
                   ["TAG_END", "%}"],
                   ["TEXT", "{% hello %}"],
                   ["TAG_START", "{%"],
                   ["WC", "~"],
                   ["TAG_NAME", "endraw"],
                   ["WC", "-"],
                   ["TAG_END", "%}"]
                 ], tokenize("{%- raw +%}{% hello %}{%~ endraw -%}"))
  end

  def test_just_comment
    assert_equal([
                   ["COMMENT_START", "{#"],
                   ["COMMENT", " some comment "],
                   ["COMMENT_END", "#}"]
                 ], tokenize("{# some comment #}"))
  end

  def test_just_comment_whitespace_control
    assert_equal([
                   ["COMMENT_START", "{#"],
                   ["WC", "-"],
                   ["COMMENT", " some comment "],
                   ["WC", "~"],
                   ["COMMENT_END", "#}"]
                 ], tokenize("{#- some comment ~#}"))
  end

  def test_comment_and_text
    assert_equal([
                   ["TEXT", "Hello, "],
                   ["COMMENT_START", "{#"],
                   ["COMMENT", " some comment "],
                   ["COMMENT_END", "#}"],
                   ["TEXT", "World"]
                 ], tokenize("Hello, {# some comment #}World"))
  end

  def test_comment_more_hashes
    assert_equal([
                   ["COMMENT_START", "{##"],
                   ["COMMENT", " some comment "],
                   ["COMMENT_END", "##}"]
                 ], tokenize("{## some comment ##}"))
  end

  def test_comment_even_more_hashes
    assert_equal([
                   ["COMMENT_START", "{###"],
                   ["COMMENT", " some comment "],
                   ["COMMENT_END", "###}"]
                 ], tokenize("{### some comment ###}"))
  end

  def test_comment_unbalanced_hashes
    assert_equal([
                   ["TEXT", "{##"],
                   ["TEXT", " some comment #}"]
                 ], tokenize("{## some comment #}"))
  end

  def test_comment_nested
    assert_equal([
                   ["COMMENT_START", "{##"],
                   ["COMMENT", " some comment {# inner comment #} "],
                   ["COMMENT_END", "##}"]
                 ], tokenize("{## some comment {# inner comment #} ##}"))
  end

  def test_object_literal
    assert_equal([
                   ["TAG_START", "{%"],
                   ["TAG_NAME", "assign"],
                   ["IDENT", "x"],
                   ["ASSIGN", "="],
                   ["LBRACE", "{"],
                   ["IDENT", "y"],
                   ["COLON", ":"],
                   ["INT", "1"],
                   ["COMMA", ","],
                   ["IDENT", "z"],
                   ["COLON", ":"],
                   ["INT", "2"],
                   ["RBRACE", "}"],
                   ["TAG_END", "%}"]
                 ], tokenize("{% assign x = {y: 1, z: 2} %}"))
  end

  def test_object_literal_end_output
    assert_equal([
                   ["OUT_START", "{{"],
                   ["LBRACE", "{"],
                   ["IDENT", "y"],
                   ["COLON", ":"],
                   ["INT", "1"],
                   ["COMMA", ","],
                   ["IDENT", "z"],
                   ["COLON", ":"],
                   ["INT", "2"],
                   ["RBRACE", "}"],
                   ["OUT_END", "}}"]
                 ], tokenize("{{ {y: 1, z: 2} }}"))
  end

  def test_object_literal_nested
    assert_equal([
                   ["OUT_START", "{{"],
                   ["LBRACE", "{"],
                   ["IDENT", "y"],
                   ["COLON", ":"],
                   ["INT", "1"],
                   ["COMMA", ","],
                   ["IDENT", "z"],
                   ["COLON", ":"],
                   ["LBRACE", "{"],
                   ["IDENT", "a"],
                   ["COLON", ":"],
                   ["INT", "2"],
                   ["RBRACE", "}"],
                   ["RBRACE", "}"],
                   ["OUT_END", "}}"]
                 ], tokenize("{{ {y: 1, z: {a: 2}} }}"))
  end
end
