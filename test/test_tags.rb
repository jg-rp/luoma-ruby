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

  describe "case tag" do
    load_test_cases("test/case_tag.json").each do |test_case|
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

  describe "define tag" do
    load_test_cases("test/define_tag.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "import tag" do
    load_test_cases("test/import_tag.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "include tag" do
    load_test_cases("test/include_tag.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "render tag" do
    load_test_cases("test/render_tag.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "if tag" do
    load_test_cases("test/if_tag.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end

  describe "comments" do
    load_test_cases("test/comments.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end
end
