# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "luoma"

require "minitest/autorun"

Minitest.load :fail_fast

#: (String) -> Array[Hash[String, untyped]]
def load_test_cases(filename)
  cases = JSON.load_file(filename)
  cases["tests"]
end

#: (Hash[String, untyped]) -> void
def assert_test_case(test_case)
  loader = if (templates = test_case["templates"])
             Luoma::HashLoader.new(templates)
           end

  env = Luoma::Environment.new(loader: loader, strict_filters: true)

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
