# frozen_string_literal: true

require "test_helper"

class TestRangeDrop < Minitest::Test
  MOCK_TEMPLATE = Luoma::Template.new(Luoma::DEFAULT_ENVIRONMENT, "", [])
  MOCK_CONTEXT = Luoma::RenderContext.new(MOCK_TEMPLATE)

  def test_inclusive_range
    assert_equal([2, 3, 4, 5], Luoma::RangeDrop.new(2, 5).to_a)
  end

  def test_length
    assert_equal(4, Luoma::RangeDrop.new(2, 5).length(MOCK_CONTEXT))
  end

  def test_first
    assert_equal(2, Luoma::RangeDrop.new(2, 5).fetch("first", MOCK_CONTEXT))
  end

  def test_last
    assert_equal(5, Luoma::RangeDrop.new(2, 5).fetch("last", MOCK_CONTEXT))
  end

  def test_size
    assert_equal(4, Luoma::RangeDrop.new(2, 5).fetch("size", MOCK_CONTEXT))
  end

  def test_slice
    assert_equal([3, 4], Luoma::RangeDrop.new(2, 5).slice(1, 3, 1, MOCK_CONTEXT).to_a)
  end
end
