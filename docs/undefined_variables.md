# Undefined variables

At render time, if a variable or path to a variable can not be resolved to a value, an instance of `Luoma::UndefinedDrop` is used in its place. We can control undefined variable rendering behavior by passing a `LuomaUndefinedDrop` singleton as the `undefined` argument when instantiating a new `Luoma::Environment`.

See https://github.com/jg-rp/luoma-ruby/blob/main/lib/luoma/drops/undefined.rb.

## Default undefined

The default _Undefined_ type is silent. It renders to the empty string, is falsy when tested for truthiness, and yields an empty iterable when looped over with the `{% for %}` tag.

```liquid2
Hello {{ nosuchthing }}
{% for thing in nosuchthing %}
    {{ thing }}
{% endfor %}
```

```title="Output"
Hello

```

## Strict undefined

`Luoma::StrictUndefinedDrop` raises a `Luoma::UndefinedVariableError` in all contexts, even when tested for truthiness.

```ruby
require "luoma"

env = Luoma::Environment.new(undefined: Luoma::StrictUndefinedDrop)

template = env.parse <<~SOURCE
  {{ nosuchthing }}
SOURCE

puts template.render

# /home/james/projects/luoma-ruby/lib/luoma/drops/undefined.rb:95:in 'Luoma::StrictUndefinedDrop#error': Luoma::UndefinedVariableError: "nosuchthing" is undefined
#   -> "{{ nosuchthing }}":1:4
#   |
# 1 | {{ nosuchthing }}
#   |    ^^^^^^^^^^^ "nosuchthing" is undefined
```

## Falsy strict undefined

`Luoma::FalsyStrictUndefinedDrop` is similar to `Luoma::StrictUndefinedDrop`, but can be tested for truthiness and equality without raising an exception.

```ruby
require "luoma"

env = Luoma::Environment.new(undefined: Luoma::FalsyStrictUndefinedDrop)

template = env.parse <<~SOURCE
  {% if nosuchthing %}TRUE{% else %}FALSE{% endif %}
SOURCE

puts template.render
```

```title="Output"
FALSE
```
