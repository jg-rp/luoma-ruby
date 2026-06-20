# frozen_string_literal: true

require "json"
require "test_helper"

begin
  # TEST_CASES = JSON.load_file("test/golden_liquid/golden_liquid.json")
  TEST_CASES = JSON.load_file("test/golden_liquid/tests/tags/raw.json")
rescue Errno::ENOENT
  puts "Error: uninitialized submodule. Try `git submodule update --init`"
  exit(1)
end

class TestGoldenLiquid < Minitest::Spec
  make_my_diffs_pretty!

  SKIP = Set[]

  describe "golden liquid" do
    TEST_CASES["tests"].reject { |t| SKIP.include?(t["name"]) }.each do |test_case|
      it test_case["name"] do
        loader = if (templates = test_case["templates"])
                   Luoma::HashLoader.new(templates)
                 end

        env = Luoma::Environment.new(loader: loader)
        if test_case["invalid"]
          assert_raises Luoma::LuomaError do
            env.parse(test_case["template"]).render(test_case["data"])
          end
        else
          template = env.parse(test_case["template"])
          if test_case["result"]
            _(template.render(test_case["data"])).must_equal test_case["result"]
          else
            _(test_case["results"]).must_include template.render(test_case["data"])
          end
        end
      end
    end
  end
end
