# Template loaders

A template loader is responsible for finding template source text given a name or identifier and will be called upon `Luoma::Environment#get_template` or by tags such as `{% render %}` and `{% include %}`. When a template can not be found, a `Luoma::TemplateNotFoundError` or `Luoma::NoSuchTemplateError` is thrown.

Every `Luoma::Environment` has exactly one configured template loader, the default of which is an empty `Luoma::HashLoader`, meaning `Environment#get_template`, `{% render %}` and `{% include %}` will always throw an error.

!!! info

    Both `NoSuchTemplateError` and `TemplateNotFoundError` inherit from `Luoma::LuomaError`. The former is a detailed error including diagnostic information about where in the parent template `{% render %}`, `{% include %}` or `{% import %}` was called.

    `NoSuchTemplateError` does not include diagnostic information. It is thrown by template loaders and surfaces when there is no parent template available, like when calling `Environment#get_template` directly.

## Built-in loaders

### `HashLoader`

`Luoma::HashLoader` is a template loader that stores template source code in a hash, mapping strings to strings. Hash keys are template names and values are template source code.

```ruby
require "luoma"

loader = Luoma::HashLoader.new(
  "index" => "This is the index. {% render 'section' %}",
  "section" => "Hi!"
)

env = Luoma::Environment.new(loader: loader)

template = env.get_template("index")
puts template.render
```

### `FileSystemLoader`

`Luoma::FileSystemLoader` is a template loader that reads template source text from files on a file system.

`FileSystemLoader.new` accepts a path or array of paths to search for files containing template source code. The `default_extension` keyword argument is a default file extension appended to the template name if it does not already have an extension.

```ruby
require "luoma"

loader = Luoma::FileSystemLoader.new(
  "./templates",
  default_extension: ".luoma"
)

env = Luoma::Environment.new(loader: loader)

# Look for `index.luoma` in the `templates` folder relative to the
# current working directory.
template = env.get_template("index")
```

### `CachingFileSystemLoader`

`Luoma::CachingFileSystemLoader` is similar to `FileSystemLoader`, but caches parsed templates in an in-memory, least recently used (LRU) cache. The default cache size is 300 templates.

```ruby
require "luoma"

loader = Luoma::CachingFileSystemLoader.new(
  "./templates",
  default_extension: ".luoma",
  capacity: 500
)

env = Luoma::Environment.new(loader: loader)

# Look for `index.luoma` in the `templates` folder relative to the
# current working directory.
template = env.get_template("index")

# Get's cached `Luoma::Template` instance.
same_template = env.get_template("index")
```

### `ChoiceLoader`

`Luoma::ChoiceLoader` is a template loader that delegates to other template loaders. Given an array of `Luoma::TemplateLoader` instances, `ChoiceLoader` will try each in turn until a template is found.

```ruby
require "luoma"

fallback_loader = Luoma::HashLoader.new(
  "layout" => "A default layout {% include content %}"
)

dynamic_loader = Luoma::CachingFileSystemLoader.new(
  "./templates",
  default_extension: ".luoma",
  capacity: 500,
  auto_reload: true
)

env = Luoma::Environment.new(
  loader: Luoma::ChoiceLoader.new([dynamic_loader, fallback_loader])
)

# Look for `layout.luoma` first, fallback to the hash loader if it
# does not exist.
template = env.get_template("layout")
```

## Custom loaders

You are encouraged to write you own template loaders to read templates from a database or process front-matter, for example. Simply extend `Luoma::TemplateLoader` and implement `#get_source`.

```ruby title="Method signature"
def get_source: (
  Luoma::Environment env,
  ::String name,
  ?context: Luoma::RenderContext? context,
  **untyped kwargs
) -> Luoma::TemplateSource
```

This example implements a simple front matter loader, which reads data from the start of a file and template source text from the rest.

```ruby
require "luoma"
require "yaml"

class FrontMatterLoader < Luoma::CachingFileSystemLoader
  RE_FRONT_MATTER = /\A\s*---\s*(.*?)\s*---\s*/m

  def get_source(env, name, context: nil, **)
    template_meta = super
    match = RE_FRONT_MATTER.match(template_meta.source)

    return template_meta unless match

    # TODO: YAML error handling and validation.
    template_meta.matter = YAML.load(match[1])
    template_meta.source = template_meta.source.slice(match[0].length..)
  end
end
```

## Load context

Sometimes a template's name alone is not enough to identify the correct source text. For such cases, `TemplateLoader#get_source` accepts optional `context` and `kwargs` to help narrow the template search space.

`context` will be set to the current `Luoma::RenderContext`, if one is available. `context` will always be `nil` when calling `Luoma::Environment#get_template` directly, as a render context does not yet exist.

`kwargs` is an arbitrary mapping of strings to unknown objects. You can use this to bootstrap the loading sequence at parse time by passing arguments to `Environment#get_template`.

By convention, built-in tags that load partial templates - `{% include %}`, `{% render %}` and `{% import %}` - set a `tag` keyword argument to the tag name (`"include"`, `"render"` and `"import"`, respectively), so you know what is tying to load a template. We could use this convention to mimic Shopify's "snippets" convention, where `{% include %}` and `{% render %}` implicitly look in a `snippets` subfolder.

## Caching loaders

The recommended way to implement template caching is to override `Luoma::TemplateLoader#load`. `load` delegates to `get_source` and calls back to `Environment#parse`, providing a convenient hook into the template loading process.

Luoma includes `Luoma::CachingLoaderMixin`, a mixin module that adds an LRU cache to template loaders. We could implement a caching version of [`HashLoader`](#hashloader) as follows.

```ruby
require "luoma"

class CachingHashLoader < Luoma::HashLoader
  include CachingLoaderMixin

  def initialize(
    templates,
    namespace_key: "",
    capacity: 300,
    thread_safe: false
  )
    super(templates)

    initialize_cache(
      auto_reload: false,
      namespace_key: namespace_key,
      capacity: capacity,
      thread_safe: thread_safe
    )
  end
end
```
