# frozen_string_literal: true

require "test_helper"

class TestStrictMode < Minitest::Test
  def test_unknown_filter
    env = Luoma::Environment.new(strict: false)
    source = "{{ 'hello' | foo }}"

    assert_equal("", env.render(source))

    env.strict = true

    assert_raises(Luoma::FilterNotFoundError) { env.render(source) }
  end

  def test_unknown_predicate
    env = Luoma::Environment.new(strict: false)

    assert_equal("false", env.render("{{ a.defined? }}"))
    assert_equal("", env.render("{{ a.foo? }}"))

    env.strict = true

    assert_raises(Luoma::PredicateNotFoundError) { env.render("{{ a.foo? }}") }
  end

  def test_missing_filter_argument
    env = Luoma::Environment.new(strict: false)
    source = "{{ 'hello' | append }}"

    assert_equal("hello", env.render(source))

    env.strict = true

    assert_raises(Luoma::FilterArgumentError) { env.render(source) }
  end

  def test_too_many_filter_arguments
    env = Luoma::Environment.new(strict: false)
    source = "{{ 'hello' | append: ' world', '!' }}"

    assert_equal("hello world", env.render(source))

    env.strict = true

    assert_raises(Luoma::FilterArgumentError) { env.render(source) }
  end

  def test_unexpected_named_argument
    env = Luoma::Environment.new(strict: false)
    source = "{{ 'hello' | append: ' world', thing: '!' }}"

    assert_equal("hello world", env.render(source))

    env.strict = true

    assert_raises(Luoma::FilterArgumentError) { env.render(source) }
  end

  def test_missing_lambda_argument
    env = Luoma::Environment.new(strict: false)
    source = <<~SOURCE.chomp
      {%- assign f = (a, b) -> (a | append: b) -%}
      {{ 'hello' | f }}
    SOURCE

    assert_equal("hello", env.render(source))

    env.strict = true

    assert_equal("hello", env.render(source))
  end

  def test_too_many_lambda_arguments
    env = Luoma::Environment.new(strict: false)
    source = <<~SOURCE.chomp
      {%- assign f = (a, b) -> (a | append: b) -%}
      {{ 'hello' | f: ' world', '!' }}
    SOURCE

    assert_equal("hello world", env.render(source))

    env.strict = true

    assert_equal("hello world", env.render(source))
  end

  def test_lambda_unexpected_named_argument
    env = Luoma::Environment.new(strict: false)
    source = <<~SOURCE.chomp
      {%- assign f = (a, b) -> (a | append: b) -%}
      {{ 'hello' | f: ' world', thing: '!' }}
    SOURCE

    assert_equal("hello world", env.render(source))

    env.strict = true

    assert_raises(Luoma::FilterArgumentError) { env.render(source) }
  end
end
