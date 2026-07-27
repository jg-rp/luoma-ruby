# frozen_string_literal: true

require "test_helper"

class TestUndefinedVariables < Minitest::Test
  def test_lax_undefined
    source = "{% if nosuchthing %}foo{% else %}bar{% endif %}"
    env = Luoma::Environment.new(undefined: Luoma::UndefinedDrop)

    assert_equal("bar", env.render(source))
    assert_equal("", env.render("{{ nosuchthing }}"))
    assert_equal("!", env.render("{% assign x = y | append: '!' %}{{ x }}"))
    assert_equal("!", env.render("{% assign x = '!' | append: y %}{{ x }}"))
  end

  def test_falsy_strict_undefined
    source = "{% if nosuchthing %}foo{% else %}bar{% endif %}"
    env = Luoma::Environment.new(undefined: Luoma::FalsyStrictUndefinedDrop)

    assert_equal("bar", env.render(source))
    assert_raises(Luoma::UndefinedVariableError) { env.render("{{ nosuchthing }}") }
    assert_raises(Luoma::UndefinedVariableError) { env.render("{% assign x = y | append: '!' %}") }
    assert_raises(Luoma::UndefinedVariableError) { env.render("{% assign x = '!' | append: y %}") }
  end

  def test_strict_undefined
    source = "{% if nosuchthing %}foo{% else %}bar{% endif %}"
    env = Luoma::Environment.new(undefined: Luoma::StrictUndefinedDrop)

    message = "\"nosuchthing\" is undefined"
    error = assert_raises(Luoma::UndefinedVariableError) { env.render(source) }
    assert_equal(message, error.message)
  end

  def test_inline_falsy_strict_undefined
    source = "{{ nosuchthing or \"bar\" }}"
    env = Luoma::Environment.new(undefined: Luoma::FalsyStrictUndefinedDrop)

    assert_equal("bar", env.render(source))
  end

  def test_disable_inline_falsy_strict_undefined
    source = "{{ nosuchthing or \"bar\" }}"
    env = Luoma::Environment.new(undefined: Luoma::StrictUndefinedDrop)

    message = "\"nosuchthing\" is undefined"
    error = assert_raises(Luoma::UndefinedVariableError) { env.render(source) }
    assert_equal(message, error.message)
  end

  def test_ternary_falsy_strict_undefined
    source = "{{ \"foo\" if nosuchthing else \"bar\" }}"
    env = Luoma::Environment.new(undefined: Luoma::FalsyStrictUndefinedDrop)

    assert_equal("bar", env.render(source))
  end

  def test_disable_ternary_falsy_strict_undefined
    source = "{{ \"foo\" if nosuchthing else \"bar\" }}"
    env = Luoma::Environment.new(undefined: Luoma::StrictUndefinedDrop)

    message = "\"nosuchthing\" is undefined"
    error = assert_raises(Luoma::UndefinedVariableError) { env.render(source) }
    assert_equal(message, error.message)
  end
end
