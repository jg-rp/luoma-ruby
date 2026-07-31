# frozen_string_literal: true

require "json"
require "test_helper"

class TestFilters < Minitest::Spec
  make_my_diffs_pretty!

  describe "abs filter" do
    load_test_cases("test/abs_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

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

  describe "append filter" do
    load_test_cases("test/append_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "at_least filter" do
    load_test_cases("test/at_least_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "at_most filter" do
    load_test_cases("test/at_most_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "capitalize filter" do
    load_test_cases("test/capitalize_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "ceil filter" do
    load_test_cases("test/ceil_filter.json").each do |test_case|
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

  describe "date filter" do
    load_test_cases("test/date_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "default filter" do
    load_test_cases("test/default_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "divided_by filter" do
    load_test_cases("test/divided_by_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "downcase filter" do
    load_test_cases("test/downcase_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "escape filter" do
    load_test_cases("test/escape_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "escape_js filter" do
    load_test_cases("test/escape_js_filter.json").each do |test_case|
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

  describe "floor filter" do
    load_test_cases("test/floor_filter.json").each do |test_case|
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

  describe "json filter" do
    load_test_cases("test/json_filter.json").each do |test_case|
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

  describe "max filter" do
    load_test_cases("test/max_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "min filter" do
    load_test_cases("test/min_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "minus filter" do
    load_test_cases("test/minus_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "modulo filter" do
    load_test_cases("test/modulo_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "plus filter" do
    load_test_cases("test/plus_filter.json").each do |test_case|
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

  describe "round filter" do
    load_test_cases("test/round_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "size filter" do
    load_test_cases("test/size_filter.json").each do |test_case|
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

  describe "sort filter" do
    load_test_cases("test/sort_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "sort_natural filter" do
    load_test_cases("test/sort_natural_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "sort_numeric filter" do
    load_test_cases("test/sort_numeric_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "sum filter" do
    load_test_cases("test/sum_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "take filter" do
    load_test_cases("test/take_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "times filter" do
    load_test_cases("test/times_filter.json").each do |test_case|
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

  describe "upcase filter" do
    load_test_cases("test/upcase_filter.json").each do |test_case|
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

  describe "zip filter" do
    load_test_cases("test/zip_filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end
end
