# Get started

Luoma is a modern template engine with a well-defined, composable, implementation agnostic expression language.

Luoma markup will be familiar to anyone who's used [Liquid](https://github.com/Shopify/liquid), [Jinja](https://jinja.palletsprojects.com/en/stable/) or [Django's template language](https://docs.djangoproject.com/en/6.0/topics/templates/#the-django-template-language), but with a strictly immutable data model, first-class blocks and expressions, and functional primitives for when data transformation is necessary.

If you're a template author, start with [Luoma for template authors](./luoma_for_template_authors.md). The rest of this documentation covers how to install, configure, use and extend Luoma if you're an application developer.

## Install

Add `'luoma'` to your Gemfile:

```ruby
gem 'luoma', '~> 0.1.0'
```

Or:

```sh
gem install luoma
```

Or:

```sh
bundle add luoma
```

## Quick start

### Render

Render a template by passing a string to `Luoma.render(source, data = nil)`. If _data_ is given it should be a hash mapping strings to objects. Hash values will be available as template variables bound to their associated keys.

```ruby
require "luoma"

puts luoma.render("Hello, {{ you }}!", "you" => "World")  # Hello, World!
```

`Luoma.render` is a convenience method equivalent to `Luoma::DEFAULT_ENVIRONMENT.parse(source).render(data)`.

### Parse

Often you'll want to render the same template multiple times with different variables. We can parse source text without immediately rendering it using `Luoma.parse(source, globals: nil)`. `Luoma.parse` returns an instance of `Luoma::Template` with a `render(data)`method.

```ruby
require "luoma"

template = Luoma.parse("Hello, {{ you }}!")
puts template.render("you" => "World") # Hello, World!
puts template.render("you" => "Luoma") # Hello, Luoma!
```

If _globals_ is given, data from _globals_ is pined to the resulting template and merged into data from `Luoma::Template#render` every time the template is rendered, with `render` arguments taking priority over pinned data.

`Luoma.parse` is a convenience method equivalent to `Luoma::DEFAULT_ENVIRONMENT.parse(source)` or `Luoma::Environment.new.parse(source)`.

### Configure

Both `Luoma.parse` and `Luoma.render` are convenience functions that use the default Luoma environment. For all but the simplest of cases you'll want to configure your own instance of `Luoma::Environment`, then load and render templates from that.

```ruby
require "luoma"

env = Luoma::Environment.new(
  loader: Luoma::CachingFileSystemLoader.new("templates/")
)

template = env.get_template("index.luoma")
another_template = env.parse("{% render 'index.luoma' %}")
# ...
```