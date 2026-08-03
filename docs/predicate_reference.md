# Built-in predicates

A _predicate_ is a trailing path segment ending with a question mark (`?`). A predicate "queries" the value obtained by resolving preceding path segments and returns `true` or `false`.

Note that a question mark (`?`) is not a valid identifier character. If a variable or property contains a literal `?`, bracket notation must be used: `foo["bar?"]`.

## array?

Resolves to `true` if the value is an array, or `false` otherwise.

```liquid2
{%- assign
  x = [1, 2, 3],
  y = "foo",
  z = null,
-%}

{{ x.array? }}
{{ y.array? }}
{{ z.array? }}
```

```title="Output"
true
false
false
```

## blank?

Resolves to `true` if the value is `null`, a string containing only whitespace, or an empty string, array or hash.

```liquid2
{%- assign
  x = "    \n    \t",
  y = "foo",
  z = [],
-%}

{{ x.blank? }}
{{ y.blank? }}
{{ z.blank? }}
```

```title="Output"
true
false
true
```

## defined?

Resolves to `true` if the value is the the special result `Nothing`. Undefined variables resolve to `Nothing`, as do math expressions that can't produce a numeric value.

```liquid2
{%- assign
  x = null,
  y = nosuchthing,
  z = {},
-%}

{{ x.defined? }}
{{ y.defined? }}
{{ z.foo.defined? }}
```

```title="Output"
true
false
false
```

## empty?

Resolves to `true` if the value is `null` or an empty string, array or hash.

```liquid2
{%- assign
  x = "    \n    \t",
  y = "",
  z = [],
-%}

{{ x.empty? }}
{{ y.empty? }}
{{ z.empty? }}
```

```title="Output"
false
true
true
```

## number?

Resolves to `true` if the value is a number type.

```liquid2
{%- assign
  x = 1,
  y = 2.3,
  z = "42",
-%}

{{ x.number? }}
{{ y.number? }}
{{ z.number? }}
```

```title="Output"
true
true
false
```

## numeric?

Resolves to `true` if the value is a number type or can be coerced to a number.

```liquid2
{%- assign
  x = null,
  y = 2.3,
  z = "42",
-%}

{{ x.numeric? }}
{{ y.numeric? }}
{{ z.numeric? }}
```

```title="Output"
false
true
true
```

## object?

Resolves to `true` if the value is an object (aka hash, dictionary or mapping).

```liquid2
{%- assign
  x = 42,
  y = {"a": 1},
  z = [1,2,3],
-%}

{{ x.object? }}
{{ y.object? }}
{{ z.object? }}
```

```title="Output"
false
true
false
```

## string?

Resolves to `true` if the value is a string type.

```liquid2
{%- assign
  x = "foo",
  y = "42",
  z = [1,2,3],
-%}

{{ x.string? }}
{{ y.string? }}
{{ z.string? }}
```

```title="Output"
true
true
false
```

## null?

Resolves to `true` if the value is `null`.

```liquid2
{%- assign
  x = null,
  y = nosuchthing,
  z = {"foo": null},
-%}

{{ x.null? }}
{{ y.null? }}
{{ z.foo.null? }}
```

```title="Output"
true
false
true
```
