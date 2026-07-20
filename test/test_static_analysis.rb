# frozen_string_literal: true

require "test_helper"

Loc = Luoma::StaticAnalysis::Location
Var = Luoma::StaticAnalysis::StaticVariable

class TestStaticAnalysis < Minitest::Test
  make_my_diffs_pretty!

  def assert_vars(got, want)
    want.each do |k, v|
      got_ = got[k] || []

      v.each_with_index do |w, i|
        segments, value = w

        assert_equal(value, got_[i]&.fetch(:value))
        assert_equal(segments, got_[i]&.fetch(:segments))
      end
    end

    assert_equal(want.size, got.size)
  end

  def assert_locations(got, want)
    want.each do |k, v|
      got_ = got[k] || []

      v.each_with_index do |w, i|
        assert_equal(w, got_[i]&.fetch(:value))
      end
    end

    assert_equal(want.size, got.size)
  end

  def test_output
    source = "{{ x | default: y, allow_false: z }}"
    analysis = Luoma.parse(source).analyze

    locals = {}
    globals = {
      "x" => [[["x"], "x"]],
      "y" => [[["y"], "y"]],
      "z" => [[["z"], "z"]]
    }
    variables = globals
    filters = { "default" => ["default: y, allow_false: z"] }
    tags = {}

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end
end
