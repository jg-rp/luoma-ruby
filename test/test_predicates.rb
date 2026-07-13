# frozen_string_literal: true

require "json"
require "test_helper"

class TestPredicates < Minitest::Spec
  make_my_diffs_pretty!

  describe "predicates" do
    load_test_cases("test/predicates.json").each do |test_case|
      it test_case["name"] do
        assert_test_case(test_case)
      end
    end
  end
end
