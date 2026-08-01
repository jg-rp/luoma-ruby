# Luoma for template authors

TODO:

## Expressions

An expression is the fundamental unit of computation within a template, representing a sequence of identifiers, literals, and operators that resolves to a value. They appear within output delimiters to render data directly to the page (e.g., `{{ user.name | upcase }}`), inside conditional tags to govern template logic (e.g., `{% if item.price > 100 %}`), and as the data sources for iterations (e.g., `{% for product in collections.frontpage %}`).

### Literals

Literals represent fixed values directly inside an expression.

`null` (alias `nil`) represents a _Null_ data value. It is not to be confused with _Nothing_, which indicates the absence of a data value.

```liquid2
{%- assign x = null -%}
{{ x.defined? }}
{{ x }}
{{ x or 'a' }}
{{ (x orElse 'b') | json }}
```

```title="Output"
true

a
null
```

Booleans `true` and `false` represent _True_ and _False_ data values, respectively.

```liquid2
{%- assign x = false, y = true -%}
{{ x and y }}
{{ x or y }}
{{ x orElse y }}
```

```title="Output"
false
true
false
```

Literal numbers can be integers, decimals, or use scientific notation.

```liquid2
{%- assign
  a = 42,
  b = 3.14,
  c = 1e3,
-%}

{{ a }}
{{ b }}
{{ c }}
```

```title="Output"
42
3.14
1000
```

String literals can be single-quoted or double-quoted. Both support JavaScript-style string interpolation and JSON-like escape sequences.

```liquid2
{%- assign
  greeting = 'Hello',
  name = "Sue",
  emoji = "\uD83D\uDE00",
-%}

{{ "${greeting}, ${name}! ${emoji}" }}
```

```title="Output"
Hello, Sue! 😀
```

Array literals are comma separated expressions surrounded by square brackets. The spread operator (`...`) expands a collection into the array literal.

```liquid2
{%- assign
  a = [1, 2, 3],
  b = ["a", "b", ["c", "d"]],
  c = [foo or 99, ...a, (b | flatten)],
-%}

{{ a }}
{{ b }}
{{ c }}
```

```title="Output"
[1,2,3]
["a","b",["c","d"]]
[99,1,2,3,["a","b","c","d"]]
```

Object literals use JavaScript-style braces (`{` and `}`) and colons (`:`). Quotes around keys are optional if they are simple identifiers.

```liquid2
{%- assign
  obj = {
    a: 1,
    "b": 2,
    'c': [3,4,5],
    d: {"foo": "bar"}
  }
-%}

{{ obj }}
{{ obj | json: pretty=true }}
```

```title="Output"
{"a":1,"b":2,"c":[3,4,5],"d":{"foo":"bar"}}
{
  "a": 1,
  "b": 2,
  "c": [
    3,
    4,
    5
  ],
  "d": {
    "foo": "bar"
  }
}
```

TODO

- **Ranges:** Enclosed in parentheses with two dots, such as `(1..5)`.

### Variables and Property Access

Variables allow accessing scoped data, object properties, and array indices:

- **Dot Notation:** Access properties using `.`, e.g., `user.name`.

- **Bracket Notation:** Access items dynamically or using string keys, e.g., `items[0]` or `settings["theme_color"]`. Dynamic sub-queries inside brackets are also supported.

- **Predicates:** Identifiers ending with `?` can be used to query predicate properties, e.g., `user.admin?`.

### Operators & Precedence

All operators are unified under a single precedence hierarchy, allowing them to be combined predictably in any context.

| Priority    | Operator Category  | Operators / Syntax                                 | Examples                      |
| ----------- | ------------------ | -------------------------------------------------- | ----------------------------- |
| 1 (Highest) | Primary & Grouping | Literals, Variables, `(...)`, Lambdas              | `(a + b)`, `x -> x.id`        |
| 2           | Unary              | `-`, `+`                                           | `-count`                      |
| 3           | Multiplicative     | `*`, `/`, `%`                                      | `total * tax_rate`            |
| 4           | Additive           | `+`, `-`                                           | `price + shipping`            |
| 5           | Filter Pipe        | <code>\|</code>                                    | <code>name \| upcase</code>   |
| 6           | Comparison & Tests | `==`, `!=`, `<`, `>`, `<=`, `>=`, `in`, `contains` | `item.qty > 0`, `tag in tags` |
| 7           | Logical NOT        | `not`                                              | `not user.logged_in`          |
| 8           | Logical AND        | `and`                                              | `has_stock and visible`       |
| 9           | Logical OR         | `or`                                               | `is_admin or is_owner`        |
| 10          | Null Coalescing    | `orElse`                                           | `title orElse fallback_title` |
| 11 (Lowest) | Inline Conditional | `... if ... else ...`                              | `a if condition else b`       |

### Filters and arguments

Filters transform values using the pipe (`|`) operator. Because filters exist directly within the expression hierarchy, they can be chained and used anywhere an expression is expected.

```liquid2
{{ products | where: (p) -> p.available | map: "title" | join: ", " }}

```

Positional arguments are separated by commas, e.g., `value | slice: 0, 5`.

Keyword arguments are specified using `:` or `=`, e.g., `font | font_face: font_display = 'swap'`.

### First-Class Lambdas

Expressions support first-class lambda functions using either `->` or `=>` arrow syntax. Lambdas accept single or grouped parameters and can be stored in variables or passed to filters:

```liquid2
{% assign is_valid = (item) -> (item.price > 0 and item.in_stock) %}

```

### Conditionals and Fallbacks

In addition to standard boolean logic, expressions support inline branching and fallback evaluation:

- **Null Coalescing (`orElse`):** Returns the right-hand operand if the left-hand operand evaluates to null.

```liquid2
{{ custom_title orElse page.title orElse "Default Title" }}

```

- **Inline Conditionals (`if ... else`):** Evaluates ternary-style conditions directly within an expression.

```liquid2
{{ "Active" if user.active else "Inactive" }}

```
