# Luoma environments

Template parsing and rendering behavior is configured using an instance of `Luoma::Environment`. Once configured, parse templates with `Environment#parse(source)` or `Environment#get_template(name)`, both of which return an instance of `Luoma::Template`.

An `Environment` is where you'd register custom filters or tags, or define variables that should be available to all templates, for example.

## The default environment

The default Luoma environment and new instances of `Luoma::Environment` constructed without any arguments are equivalent to passing the following arguments to `Environment.new`.

```ruby
env = Luoma::Environment.new(
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

Global template variables are those added by application developers, as opposed to local variables created by template authors with tags such as `{% assign %}` and `{% capture %}`. Globals can come from the following places, in order of highest to lowest priority.

1. The _data_ argument to `Luoma.render`, `Luoma::Environment#render` or `Luoma::Template#render`.
2. "overlay" or "matter" data provided by a template loader and bound to a `Luoma::Template` instance. This could be front matter parsed from the beginning of a template source file, or data from a database, for example.
3. The `globals` argument to `Luoma.parse` or `Luoma::Environment#parse`. These variables are pinned to the resulting template.
4. The `globals` argument when constructing a new `Luoma::Environment`. These variables are pinned to the environment and will be merged into other global data for every template rendered from the environment.

You can change the global variable source priority by extending and overriding `Luoma::Environment#makeGlobals` and/or `Luoma::Template#makeGlobals`.

## Resource limits

For deployments where template authors are untrusted, you can set limits on some resources to avoid malicious templates from consuming too much memory or too many CPU cycles. If any limit is exceeded, a `Luoma::ResourceLimitError` is raised.

!!! note

    The following "scores" are non-specific measures of usage modelled on Shopify/liquid resource limits.

    These numbers are for illustration purposes. You'll need to do a bit of trial and error to find the limits that work best for you.

```ruby
require "luoma"

env = Luoma::Environment.new(
  # Maximum of 2000 "bytes" assigned with the assign/capture tags per template
  # or partial template.
  max_assign_score: 2000,

  # Maximum of 10,000 "bytes" assigned with the assign/capture tags for the
  # root template and all partial templates combined.
  max_assign_score_cumulative: 10000,

  # Maximum nesting of 30 `for` loops and/or `render` tags, for example.
  max_context_depth: 30,

  # Maximum of 1000 nodes (text and markup in the template syntax tree) rendered
  # per template.
  max_render_score: 1000,

  # Maximum of 5000 nodes (text and markup in the template syntax tree) rendered
  # for the root template and any rendered partial templates combined.
  max_render_score_cumulative: 5000,

  # Maximum of 15,000 bytes written to the output buffer.
  max_render_size: 15000,
)
```

## Auto trim

TODO:

## Strict filters

TODO: