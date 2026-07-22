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

  def test_for
    source = [
      "{% for x in (1..y) %}",
      "  {{ x }}",
      "{% break %}",
      "{% else %}",
      "  {{ z }}",
      "{% continue %}",
      "{% endfor %}"
    ].join("\n")

    analysis = Luoma.parse(source).analyze

    locals = {}
    globals = {
      "y" => [[["y"], "y"]],
      "z" => [[["z"], "z"]]
    }
    variables = {
      "y" => [[["y"], "y"]],
      "x" => [[["x"], "x"]],
      "z" => [[["z"], "z"]]
    }
    filters = {}
    tags = {
      "for" => ["for"],
      "break" => ["break"],
      "continue" => ["continue"]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_for_with_index_binding
    source = [
      "{% for x, i in (1..y) %}",
      "  {{ x }}",
      "  {{ i }}",
      "{% break %}",
      "{% else %}",
      "  {{ z }}",
      "{% continue %}",
      "{% endfor %}"
    ].join("\n")

    analysis = Luoma.parse(source).analyze

    locals = {}
    globals = {
      "y" => [[["y"], "y"]],
      "z" => [[["z"], "z"]]
    }
    variables = {
      "y" => [[["y"], "y"]],
      "x" => [[["x"], "x"]],
      "i" => [[["i"], "i"]],
      "z" => [[["z"], "z"]]
    }
    filters = {}
    tags = {
      "for" => ["for"],
      "break" => ["break"],
      "continue" => ["continue"]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_if
    source = [
      "{% if x or z %}",
      "  {{ a }}",
      "{% elsif y %}",
      "  {{ b }}",
      "{% else %}",
      "  {{ c }}",
      "{% endif %}"
    ].join("\n")

    analysis = Luoma.parse(source).analyze

    locals = {}
    globals = {
      "x" => [[["x"], "x"]],
      "z" => [[["z"], "z"]],
      "a" => [[["a"], "a"]],
      "y" => [[["y"], "y"]],
      "b" => [[["b"], "b"]],
      "c" => [[["c"], "c"]]
    }
    variables = globals
    filters = {}
    tags = {
      "if" => ["if"],
      "elsif" => ["elsif"],
      "else" => ["else"]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_include
    loader = Luoma::HashLoader.new({ "a" => "{{ x }}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% include 'a' %}"
    analysis = env.parse(source).analyze(include_partials: true)

    locals = {}
    globals = {
      "x" => [[["x"], "x"]]
    }
    variables = globals
    filters = {}
    tags = {
      "include" => ["include"]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_include_assign
    loader = Luoma::HashLoader.new({ "a" => "{{ x }}{% assign y = 42 %}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% include 'a' %}{{ y }}"
    analysis = env.parse(source).analyze(include_partials: true)

    locals = {
      "y" => [[["y"], "y"]]
    }
    globals = {
      "x" => [[["x"], "x"]]
    }
    variables = {
      "x" => [[["x"], "x"]],
      "y" => [[["y"], "y"]]
    }
    filters = {}
    tags = {
      "include" => ["include"],
      "assign" => ["assign"]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_include_twice
    loader = Luoma::HashLoader.new({ "a" => "{{ x }}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% include 'a' %}{% include 'a' %}"
    analysis = env.parse(source).analyze(include_partials: true)

    locals = {}
    globals = {
      "x" => [[["x"], "x"]]
    }
    variables = globals
    filters = {}
    tags = {
      "include" => %w[include include]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_include_recursive
    loader = Luoma::HashLoader.new({ "a" => "{{ x }}{% include 'a' %}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% include 'a' %}"
    analysis = env.parse(source).analyze(include_partials: true)

    locals = {}
    globals = {
      "x" => [[["x"], "x"]]
    }
    variables = globals
    filters = {}
    tags = {
      "include" => %w[include include]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_include_with_arguments
    loader = Luoma::HashLoader.new({ "a" => "{{ x | append: y }}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% include 'a', x:y, z:42 %}{{ x }}"
    analysis = env.parse(source).analyze(include_partials: true)

    locals = {}
    globals = {
      "y" => [
        [["y"], "y"],
        [["y"], "y"]
      ]

    }
    variables = {
      "y" => [
        [["y"], "y"],
        [["y"], "y"]
      ],
      "x" => [
        [["x"], "x"],
        [["x"], "x"]
      ]
    }
    filters = {
      "append" => ["append: y"]
    }
    tags = {
      "include" => %w[include]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_include_with_dynamic_name
    loader = Luoma::HashLoader.new({ "a" => "{{ x | append: y }}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% include b %}"

    assert_raises Luoma::TemplateNotFoundError do
      env.parse(source).analyze(include_partials: true)
    end
  end

  def test_include_template_not_found
    loader = Luoma::HashLoader.new({ "a" => "{{ x | append: y }}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% include 'nosuchthing' %}"

    assert_raises Luoma::TemplateNotFoundError do
      env.parse(source).analyze(include_partials: true)
    end
  end

  def test_render_assign
    loader = Luoma::HashLoader.new({ "a" => "{{ x }}{% assign y = 42 %}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% render 'a' %}{{ y }}"
    analysis = env.parse(source).analyze(include_partials: true)

    locals = {
      "y" => [[["y"], "y"]]
    }
    globals = {
      "x" => [[["x"], "x"]],
      "y" => [[["y"], "y"]]
    }
    variables = globals
    filters = {}
    tags = {
      "render" => %w[render],
      "assign" => %w[assign]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_render_twice
    loader = Luoma::HashLoader.new({ "a" => "{{ x }}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% render 'a' %}{% render 'a' %}"
    analysis = env.parse(source).analyze(include_partials: true)

    locals = {}
    globals = {
      "x" => [[["x"], "x"]]
    }
    variables = globals
    filters = {}
    tags = {
      "render" => %w[render render]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_render_recursive
    loader = Luoma::HashLoader.new({ "a" => "{{ x }}{% render 'a' %}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% render 'a' %}"
    analysis = env.parse(source).analyze(include_partials: true)

    locals = {}
    globals = {
      "x" => [[["x"], "x"]]
    }
    variables = globals
    filters = {}
    tags = {
      "render" => %w[render render]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_render_with_arguments
    loader = Luoma::HashLoader.new({ "a" => "{{ x | append: y }}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% render 'a', x:y, z:42 %}{{ x }}"
    analysis = env.parse(source).analyze(include_partials: true)

    locals = {}
    globals = {
      "y" => [
        [["y"], "y"],
        [["y"], "y"]
      ],
      "x" => [
        [["x"], "x"]
      ]
    }
    variables = {
      "y" => [
        [["y"], "y"],
        [["y"], "y"]
      ],
      "x" => [
        [["x"], "x"],
        [["x"], "x"]
      ]
    }
    filters = {
      "append" => ["append: y"]
    }
    tags = {
      "render" => %w[render]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_render_template_not_found
    loader = Luoma::HashLoader.new({ "a" => "{{ x | append: y }}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% render 'nosuchthing' %}"

    assert_raises Luoma::TemplateNotFoundError do
      env.parse(source).analyze(include_partials: true)
    end
  end

  def test_import
    loader = Luoma::HashLoader.new({ "a" => "{{ x }}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% import 'a' %}"
    analysis = env.parse(source).analyze(include_partials: true)

    locals = {}
    globals = {
      "x" => [[["x"], "x"]]
    }
    variables = globals
    filters = {}
    tags = {
      "import" => ["import"]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_import_assign
    loader = Luoma::HashLoader.new({ "a" => "{{ x }}{% assign y = 42 %}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% import 'a' %}{{ y }}"
    analysis = env.parse(source).analyze(include_partials: true)

    locals = {
      "y" => [[["y"], "y"]]
    }
    globals = {
      "x" => [[["x"], "x"]]
    }
    variables = {
      "x" => [[["x"], "x"]],
      "y" => [[["y"], "y"]]
    }
    filters = {}
    tags = {
      "import" => ["import"],
      "assign" => ["assign"]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_import_twice
    loader = Luoma::HashLoader.new({ "a" => "{{ x }}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% import 'a' %}{% import 'a' %}"
    analysis = env.parse(source).analyze(include_partials: true)

    locals = {}
    globals = {
      "x" => [[["x"], "x"]]
    }
    variables = globals
    filters = {}
    tags = {
      "import" => %w[import import]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_import_recursive
    loader = Luoma::HashLoader.new({ "a" => "{{ x }}{% import 'a' %}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% import 'a' %}"
    analysis = env.parse(source).analyze(include_partials: true)

    locals = {}
    globals = {
      "x" => [[["x"], "x"]]
    }
    variables = globals
    filters = {}
    tags = {
      "import" => %w[import import]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_import_with_arguments
    loader = Luoma::HashLoader.new({ "a" => "{{ x | append: y }}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% import 'a', x:y, z:42 %}{{ x }}"
    analysis = env.parse(source).analyze(include_partials: true)

    locals = {}
    globals = {
      "y" => [
        [["y"], "y"],
        [["y"], "y"]
      ]

    }
    variables = {
      "y" => [
        [["y"], "y"],
        [["y"], "y"]
      ],
      "x" => [
        [["x"], "x"],
        [["x"], "x"]
      ]
    }
    filters = {
      "append" => ["append: y"]
    }
    tags = {
      "import" => %w[import]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_import_template_not_found
    loader = Luoma::HashLoader.new({ "a" => "{{ x | append: y }}" })
    env = Luoma::Environment.new(loader: loader)
    source = "{% import 'nosuchthing' %}"

    assert_raises Luoma::TemplateNotFoundError do
      env.parse(source).analyze(include_partials: true)
    end
  end

  def test_with
    source = <<~LIQUID.chomp
      {% with a: 1, b: 3.4 -%}
      {{ a }} + {{ b }} = {{ a | plus: b }}
      {%- endwith -%}
      {{ a }}
    LIQUID

    analysis = Luoma.parse(source).analyze(include_partials: true)

    locals = {}
    globals = {
      "a" => [[["a"], "a"]]
    }
    variables = {
      "a" => [
        [["a"], "a"],
        [["a"], "a"],
        [["a"], "a"]
      ],
      "b" => [
        [["b"], "b"],
        [["b"], "b"]
      ]
    }
    filters = {
      "plus" => ["plus: b"]
    }
    tags = {
      "with" => %w[with]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  def test_lambda
    source = "{% assign y = 42 %}{% assign x = a | where: (i, j) => (i.foo.bar == j) %}"
    analysis = Luoma.parse(source).analyze(include_partials: true)

    locals = {
      "y" => [[["y"], "y"]],
      "x" => [[["x"], "x"]]
    }
    globals = {
      "a" => [[["a"], "a"]]
    }
    variables = {
      "a" => [[["a"], "a"]],
      "i" => [[%w[i foo bar], "i.foo.bar"]],
      "j" => [[["j"], "j"]]
    }
    filters = {
      "where" => ["where: (i, j) => (i.foo.bar == j)"]
    }
    tags = {
      "assign" => %w[assign assign]
    }

    assert_vars(analysis.locals, locals)
    assert_vars(analysis.globals, globals)
    assert_vars(analysis.variables, variables)
    assert_locations(analysis.filters, filters)
    assert_locations(analysis.tags, tags)
  end

  # TODO: define
end
