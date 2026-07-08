# frozen_string_literal: true

require "json"
require "test_helper"

class TestTags < Minitest::Spec
  make_my_diffs_pretty!

  describe "assign tag" do
    load_test_cases("test/assign_tag.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "with tag" do
    load_test_cases("test/with_tag.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "for tag" do
    load_test_cases("test/for_tag.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end
end
