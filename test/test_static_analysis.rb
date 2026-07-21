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

  def test_bracket_notation
    source = "{{ x['y'].title }}"
    analysis = Luoma.parse(source).analyze

    locals = {}
    globals = {
      "x" => [[%w[x y title], "x['y'].title"]]
    }
    variables = globals
    filters = {}
    tags = {}

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_quoted_dot_notation
    source = "{{ some['foo.bar'] }}"
    analysis = Luoma.parse(source).analyze

    locals = {}
    globals = {
      "some" => [[["some", "foo.bar"], "some['foo.bar']"]]
    }
    variables = globals
    filters = {}
    tags = {}

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_nested_queries
    source = "{{ x[y.z].title }}"
    analysis = Luoma.parse(source).analyze

    locals = {}
    globals = {
      "x" => [[["x", %w[y z], "title"], "x[y.z].title"]],
      "y" => [[%w[y z], "y.z"]]
    }
    variables = globals
    filters = {}
    tags = {}

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  # def test_dynamic_root_query
  #   source = "{{ [a.b] }}"
  #   analysis = Luoma.parse(source).analyze

  #   locals = {}
  #   globals = {
  #     "a.b" => [[[%w[a b]], "a.b"]],
  #     "a" => [[%w[a b], "a.b"]]
  #   }
  #   variables = globals
  #   filters = {}
  #   tags = {}

  #   assert_vars(analysis.locals, locals)
  #   assert_vars(analysis.globals, globals)
  #   assert_vars(analysis.variables, variables)
  #   assert_locations(analysis.filters, filters)
  #   assert_locations(analysis.tags, tags)
  # end

  def test_variable_segments
    source = "{{ a['b.c'] }}{{ d[e.f][4] }}"
    analysis = Luoma.parse(source).analyze

    locals = {}
    globals = {
      "a" => [[["a", "b.c"], "a['b.c']"]],
      "d" => [[["d", %w[e f], 4], "d[e.f][4]"]],
      "e" => [[%w[e f], "e.f"]]
    }
    variables = globals
    filters = {}
    tags = {}

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_assign
    source = "{% assign x = y | append: z %}"
    analysis = Luoma.parse(source).analyze

    locals = {
      "x" => [[["x"], "x"]]
    }
    globals = {
      "y" => [[["y"], "y"]],
      "z" => [[["z"], "z"]]
    }
    variables = globals
    filters = {
      "append" => ["append: z"]
    }
    tags = {
      "assign" => ["assign"]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_multi_assign
    source = "{% assign x = y, a = 2 %}"
    analysis = Luoma.parse(source).analyze

    locals = {
      "x" => [[["x"], "x"]],
      "a" => [[["a"], "a"]]
    }
    globals = {
      "y" => [[["y"], "y"]]
    }
    variables = globals
    filters = {}
    tags = {
      "assign" => ["assign"]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_assign_predicate
    source = "{% assign x = y.defined? %}"
    analysis = Luoma.parse(source).analyze

    locals = {
      "x" => [[["x"], "x"]]
    }
    globals = {
      "y" => [[["y"], "y"]]
    }
    variables = globals
    filters = {}
    tags = {
      "assign" => ["assign"]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_capture
    source = "{% capture x %}{% if y %}z{% endif %}{% endcapture %}"
    analysis = Luoma.parse(source).analyze

    locals = {
      "x" => [[["x"], "x"]]
    }
    globals = {
      "y" => [[["y"], "y"]]
    }
    variables = globals
    filters = {}
    tags = {
      "capture" => ["capture"],
      "if" => ["if"]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_case
    source = [
      "{% case x %}",
      "{% when y %}",
      "  {{ a }}",
      "{% when z %}",
      "  {{ b }}",
      "{% else %}",
      "  {{ c }}",
      "{% endcase %}"
    ].join("\n")

    analysis = Luoma.parse(source).analyze

    locals = {}
    globals = {
      "x" => [[["x"], "x"]],
      "y" => [[["y"], "y"]],
      "a" => [[["a"], "a"]],
      "z" => [[["z"], "z"]],
      "b" => [[["b"], "b"]],
      "c" => [[["c"], "c"]]
    }
    variables = globals
    filters = {}
    tags = {
      "case" => ["case"],
      "when" => %w[when when],
      "else" => ["else"]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_case_predicates
    source = [
      "{% case x %}",
      "{% when string? %}",
      "  {{ a }}",
      "{% else %}",
      "  {{ b }}",
      "{% endcase %}"
    ].join("\n")

    analysis = Luoma.parse(source).analyze

    locals = {}
    globals = {
      "x" => [[["x"], "x"]],
      "a" => [[["a"], "a"]],
      "b" => [[["b"], "b"]]
    }
    variables = globals
    filters = {}
    tags = {
      "case" => ["case"],
      "when" => %w[when],
      "else" => ["else"]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end
end
