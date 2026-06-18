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
    assert_equal([3, 4], Luoma::RangeDrop.new(2, 5).slice(1, 2, false).to_a)
  end

  def test_slice_negative_offset
    assert_equal([4, 5], Luoma::RangeDrop.new(2, 5).slice(-2, 2, false).to_a)
  end

  def test_slice_just_offset
    assert_equal([3, 4, 5], Luoma::RangeDrop.new(2, 5).slice(1, nil, false).to_a)
  end

  def test_slice_just_offset_out_of_range
    assert_equal([], Luoma::RangeDrop.new(2, 5).slice(10, nil, false).to_a)
  end

  def test_slice_just_limit
    assert_equal([2, 3], Luoma::RangeDrop.new(2, 5).slice(nil, 2, false).to_a)
  end

  def test_slice_just_limit_negative
    assert_equal([], Luoma::RangeDrop.new(2, 5).slice(nil, -2, false).to_a)
  end

  def test_slice_start_out_of_range
    assert_equal([], Luoma::RangeDrop.new(2, 5).slice(6, 2, false).to_a)
  end

  def test_slice_reversed
    assert_equal([4, 3], Luoma::RangeDrop.new(2, 5).slice(1, 2, true).to_a)
  end
end
