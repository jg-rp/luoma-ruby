# frozen_string_literal: true

require "json"
require "test_helper"

class TestFilters < Minitest::Spec
  make_my_diffs_pretty!

  describe "join filter" do
    load_test_cases("test/join_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "join flatten" do
    load_test_cases("test/flatten_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "slice filter" do
    load_test_cases("test/slice_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end
end
