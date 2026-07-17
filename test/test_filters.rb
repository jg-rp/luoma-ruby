# frozen_string_literal: true

require "json"
require "test_helper"

class TestFilters < Minitest::Spec
  make_my_diffs_pretty!

  describe "all filter" do
    load_test_cases("test/all_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "any filter" do
    load_test_cases("test/any_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "compact filter" do
    load_test_cases("test/compact_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "concat filter" do
    load_test_cases("test/concat_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "find filter" do
    load_test_cases("test/find_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "find_index filter" do
    load_test_cases("test/find_index_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "first filter" do
    load_test_cases("test/first_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "flatten filter" do
    load_test_cases("test/flatten_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "join filter" do
    load_test_cases("test/join_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "last filter" do
    load_test_cases("test/last_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "map filter" do
    load_test_cases("test/map_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "reject filter" do
    load_test_cases("test/reject_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "reverse filter" do
    load_test_cases("test/reverse_filter.json").each do |test_case|
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

  describe "uniq filter" do
    load_test_cases("test/uniq_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "where filter" do
    load_test_cases("test/where_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end
end
