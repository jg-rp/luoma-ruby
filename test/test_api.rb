# frozen_string_literal: true

require "test_helper"

class TestAPI < Minitest::Test
  def test_parse_from_string
    source = "Hello, {{ you }}!"
    data = { "you" => "World" }
    template = Luoma.parse(source)

    assert_equal("Hello, World!", template.render(data))
  end

  def test_parse_from_string_with_global_data
    source = "Hello, {{ you }}!"
    data = { "you" => "World" }
    template = Luoma.parse(source, globals: data)

    assert_equal("Hello, World!", template.render)
  end

  def test_template_globals_take_priority_over_environment_globals
    env = Luoma::Environment.new(
      loader: Luoma::HashLoader.new({ "index" => "Hello, {{ you }}!" }),
      globals: { "you" => "World" }
    )

    template = env.parse("{% render 'index' %}", globals: { "you" => "there" })

    assert_equal("Hello, there!", template.render)
  end
end
