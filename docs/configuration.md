# Luoma environments

Template parsing and rendering behavior is configured using an instance of `Luoma::Environment`. Once configured, parse templates with `Environment#parse(source)` or `Environment#get_template(name)`, both of which return an instance of `Luoma::Template`.

An `Environment` is where you'd register custom filters or tags, or define variables that should be available to all templates, for example.

## The default environment

The default Luoma environment and new instances of `Luoma::Environment` constructed without any arguments are equivalent to passing the following arguments to `Environment.new`.

```ruby
env = Luoma::Environment.new(
  auto_escape: nil,
  auto_trim: nil,
  globals: nil,
  lexer: Luoma::UnifiedLexer,
  loader: Luoma::HashLoader.new({}),
  max_assign_score_cumulative: nil,
  max_assign_score: nil,
  max_context_depth: 30,
  max_render_score_cumulative: nil,
  max_render_score: nil,
  max_render_size: nil,
  parser: Luoma::UnifiedParser,
  strict_filters: false,
  suppress_blank_control_flow_blocks: true,
  undefined: Luoma::UndefinedDrop
)
```

Top-level convenience methods `Luoma.parse` and `Luoma.render` always use the default environment.

## Managing tags, filters and predicates

New instances of `Luoma::Environment` and the [default Luoma environment](#the-default-environment) have all standard tags, filters and predicates enabled by default. `Environment.tags`, `Environment.filters` and `Environment.predicates` are hashes mapping strings to `_Tag`, filter callables and predicate callables, respectively. You can add, remove, replace or alias tags, filters and predicates in an environment by updating these mappings after environment initialization.

This example removes th `{% include %}` tag and renames `downcase` to `lower` and `upcase` to `upper`.

```ruby

require "luoma"

env = Luoma::Environment.new
env.tags.delete("include")
env.filters["lower"] = env.tags.delete("downcase")
env.filters["upper"] = env.tags.delete("upcase")
```

Alternatively, you can extend `Luoma::Environment` and override `setup_tags_filters_and_predicates`.

```ruby
require "luoma"

class MyLuomaEnv < Luoma::Environment
  #: () -> void
  def setup_tags_filters_and_predicates
    super
    @tags.delete("include")
  end
end

env = MyLuomaEnv.new
# ...
```

## Global variables

TODO:

## HTML auto escape

TODO:

## Resource limits

TODO:
