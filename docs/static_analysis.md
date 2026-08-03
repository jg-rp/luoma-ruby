# Static analysis

Instances of `Luoma::Template` - as returned by `Luoma::parse`, `Luoma::Environment#parse` and `Luoma::Environment#get_template` - include methods for inspecting a template's variable, tag a filter usage, without rendering the template.

By default, all of the following methods with **not** attempt to load and analyze partial templates via `{% include %}`, `{% render %}` and `{% import %}`. Pass `include_partials: true` to analyze partial templates too.

See https://github.com/jg-rp/luoma-ruby/blob/main/lib/luoma/template.rb.

## All variables

`Template#variables` returns an array of distinct, top-level variable names, without path segments. The resulting array will include variables that are local to the template, like those created with `{% assign %}`, or are in scope from `{% for %}` tags.

```ruby
require "luoma"

template = Luoma.parse <<~SOURCE
  Hello, {{ you }}!
  {% assign x = 'foo' | upcase %}

  {% for ch in x %}
      - {{ ch }}
  {% endfor %}

  Goodbye, {{ you.first_name | capitalize }} {{ you.last_name }}
  Goodbye, {{ you.first_name }} {{ you.last_name }}`);
SOURCE

pp template.variables
```

```title="Output"
["you", "x", "ch"]
```

### Paths

`Template#variable_paths` returns an array of variables including all path segments. The resulting array will include variables that are local to the template, like those created with `{% assign %}`, or are in scope from `{% for %}` tags.

```ruby
# ... continued from above
pp template.variable_paths
```

```title="Output"
["you", "you.first_name", "you.last_name", "x", "ch"]
```

### Segments

`Template#variable_segments` returns an array of variables as a nested array of segments. The resulting array will include variables that are local to the template, like those created with `{% assign %}`, or are in scope from `{% for %}` tags.

```ruby
# ... continued from above
pp template.variable_segments
```

```title="Output"
[["you"], ["you", "first_name"], ["you", "last_name"], ["x"], ["ch"]]
```

## Global variables

`Template#global_variables` returns an array of top-level variable names excluding local and block scoped names.

Notice that `x` and `ch` are excluded from this result compared to `Template#variables` above.

```ruby
# ... continued from above
pp template.global_variables
```

```title="Output"
["you"]
```

### Paths

`Template#global_variable_paths` returns an array global variables including path segments.

```ruby
# ... continued from above
pp template.global_variable_paths
```

```title="Output"
["you", "you.first_name", "you.last_name"]
```

### Segments

`Template#global_variable_segments` return an array global variables as nested arrays of segments.

```ruby
# ... continued from above
pp template.global_variable_segments
```

```title="Output"
[["you"], ["you", "first_name"], ["you", "last_name"]]
```

## Filter names

`Template#filter_names` returns an array of filter names that appear in the template.

```ruby
# ... continued from above
pp template.filter_names
```

```title="Output"
["upcase", "capitalize"]
```

## Tag names

`Template#tag_names` returns an array of tag names that appear in the template.

```ruby
# ... continued from above
pp template.tag_names
```

```title="Output"
["assign", "for"]
```

## Variable, tag and filter locations

`Template#analyze` returns an instance of [`Luoma::StaticAnalysis::Result`](https://github.com/jg-rp/luoma-ruby/blob/main/lib/luoma/static_analysis.rb) containing all of the information provided by the other methods described on this page, plus the location (template name, span, line and column numbers) of every variable, tag and filter, each of which can appear many times across many templates.

## Comments

`Template#comments` returns an array of `Luoma::Comment` instances with `token` and `text` attributes.

```ruby
require "luoma"

template = Luoma.parse <<~SOURCE
  {##
   # some doc comment
   ##}

  Hello!

  {#
      some comment
  #}

  {% if false %}
    {# an inline comment #}
  {% endif %}
SOURCE

template.comments.each { |node| puts node.text.inspect }
```

```title="Output"
"\n # some doc comment\n "
"\n    some comment\n"
" an inline comment "
```
