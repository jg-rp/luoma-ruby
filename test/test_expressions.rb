# frozen_string_literal: true

require "json"
require "test_helper"

#: (String) -> Array[Hash[String, untyped]]
def load_test_cases(filename)
  cases = JSON.load_file(filename)
  cases["tests"]
end

#: (Hash[String, untyped]) -> void
def assert_test_case(test_case)
  if test_case["invalid"]
    assert_raises Luoma::LuomaError do
      Luoma.parse("{{ #{test_case["expression"]} }}").render(test_case["data"])
    end
  else
    template = Luoma.parse("{{ #{test_case["expression"]} }}")
    if test_case["result"]
      _(template.render(test_case["data"])).must_equal test_case["result"]
    else
      _(test_case["results"]).must_include template.render(test_case["data"])
    end
  end
end

class TestExpressions < Minitest::Spec
  make_my_diffs_pretty!

  describe "arithmetic" do
    load_test_cases("test/arithmetic.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "array" do
    load_test_cases("test/array.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "filter" do
    load_test_cases("test/filter.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "lambda" do
    load_test_cases("test/lambda.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "literal" do
    load_test_cases("test/literal.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "logic" do
    load_test_cases("test/logic.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "object" do
    load_test_cases("test/object.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "string" do
    load_test_cases("test/string.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "ternary" do
    load_test_cases("test/ternary.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end
end
