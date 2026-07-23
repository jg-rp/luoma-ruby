# frozen_string_literal: true

require "test_helper"

class TestResourceLimits < Minitest::Test
  def test_assign_score_limit
    env = Luoma::Environment.new(max_assign_score: 5)
    template = env.parse("{% assign greeting = 'hello' %}")
    ctx = Luoma::RenderContext.new(template)

    template.render_with_context(ctx, +"")

    assert_equal(5, ctx.assign_score)

    env.max_assign_score = 4
    assert_raises Luoma::ResourceLimitError do
      template.render
    end
  end

  def test_cumulative_assign_score_limit
    loader = Luoma::HashLoader.new({ "foo" => "{% assign bar = 'goodbye' %}" })
    env = Luoma::Environment.new(
      loader: loader,
      max_assign_score_cumulative: 12
    )
    template = env.parse("{% assign greeting = 'hello' %}{% render 'foo' %}")
    ctx = Luoma::RenderContext.new(template)

    template.render_with_context(ctx, +"")

    # The assign score from "foo" has been subtracted by this point.
    assert_equal(5, ctx.assign_score_cumulative)

    env.max_assign_score_cumulative = 11
    assert_raises Luoma::ResourceLimitError do
      template.render
    end
  end

  def test_render_score_limit
    env = Luoma::Environment.new(max_render_score: 3)
    template = env.parse("Hello, {{ you }}!")
    ctx = Luoma::RenderContext.new(template)

    template.render_with_context(ctx, +"")

    assert_equal(3, ctx.render_score)

    env.max_render_score = 2
    assert_raises Luoma::ResourceLimitError do
      template.render
    end
  end

  def test_cumulative_render_score_limit
    loader = Luoma::HashLoader.new({ "foo" => "{{ you }}!" })
    env = Luoma::Environment.new(
      loader: loader,
      max_render_score_cumulative: 4
    )
    template = env.parse("Hello, {% render 'foo' %}")
    ctx = Luoma::RenderContext.new(template)

    template.render_with_context(ctx, +"")

    assert_equal(4, ctx.render_score_cumulative)

    env.max_render_score_cumulative = 3
    assert_raises Luoma::ResourceLimitError do
      template.render
    end
  end

  def test_render_size_limit
    loader = Luoma::HashLoader.new({ "foo" => "World" })
    env = Luoma::Environment.new(
      loader: loader,
      max_render_size: 12
    )
    template = env.parse("Hello, {% render 'foo' %}")
    ctx = Luoma::RenderContext.new(template)
    buf = +""

    template.render_with_context(ctx, buf)

    assert_equal(12, buf.bytesize)

    env.max_render_size = 11
    assert_raises Luoma::ResourceLimitError do
      template.render
    end
  end

  def test_context_depth_limit
    loader = Luoma::HashLoader.new(
      { "foo" => "{% render 'bar' %}",
        "bar" => "{% render 'foo' %}" }
    )
    env = Luoma::Environment.new(loader: loader)
    template = env.get_template("foo")

    assert_raises Luoma::ContextDepthError do
      template.render
    end
  end
end
