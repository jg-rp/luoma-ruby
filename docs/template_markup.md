# Luoma template markup

Luoma is a template language. Source text (the template) contains placeholders for variables, conditional expressions for including or excluding blocks of text, and loops for repeating blocks of text. Plus other syntax for manipulating variables and combining multiple templates into a single output.

Output text is the result of _rendering_ a template given some data model. It is that data model that provides the variables referenced in a template's expressions.

Luoma is commonly used with HTML or Markdown, but can be used with any text-based content.

## Markup

Luoma markup is delimited by double curly brackets for [output statements](#output) (`{{ ... }}`), curly brackets with percents for [tags](#tags) (`{% ... %}`), and curly brackets with hashes for [comments](#comments) (`{# ... #}`).

Everything else outside these markup delimiters is plain content and, with the exception of [whitespace control](#whitespace-control), wil be output unchanged.

### Output

`{{ site_description }}` and `{{ item.title | capitalize }}` are examples of [output statements](./tag_reference.md#output). Expressions surrounded by double curly braces, `{{` and `}}`, will be evaluated and the result inserted into the output text.

In this example `Hello, ` and `!` are plain content, and `you` is a [variable](#variables-and-property-access). At render time, `you` is resolved to a value and `{{ you }}` is replaced with that value.

```liquid2 title="Template"
Hello, {{ you }}!
```

If `you` is assigned the value `"World"`, we'd get the following output.

```title="Output"
Hello, World!
```

### Filters

TODO:

### Tags

TODO:

### Comments

TODO:

### Content

TODO:

### Whitespace control

TODO:

## Expressions

An expression is the fundamental unit of computation within a template. Every syntactically correct expression is guaranteed to resolve to a value.

Expressions appear, for example, within output delimiters to render data directly to the page (`{{ user.name | upcase }}`), inside conditional tags to govern template logic (`{% if item.price > 100 %}`), and as the data sources for iterations (`{% for product in collections.frontpage %}`).

Here we'll give a brief tour of the expression language used in Luoma templates. See also the formal [expression language specification](https://jg-rp.github.io/template-expression-spec/).

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

Literal numbers can be integers or decimals, and use scientific notation.

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

Array literals are lists of comma separated expressions surrounded by square brackets. The spread operator (`...`) expands a collection into the array literal.

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

A range literal represents a lazy sequence of increasing integers. The start and end (inclusive) integers are separated by two dots (`..`) and surrounded by parentheses, `(1..5)`.

```liquid2
{% for x in (2..8) ~%}
  - {{ x }}
{% endfor -%}
```

```title="Output"
  - 2
  - 3
  - 4
  - 5
  - 6
  - 7
  - 8
```

### Variables and Property Access

Access variables by name. If a variable name contains reserved characters, use bracket notation.

```liquid2
{{ some_name }}
{{ ["name with spaces"] }}
{{ [path.to.variable] }}
```

Object properties are accessed using dot notation, or brackets when the property name contains reserved characters.

```liquid2
{{ foo.some_property }}
{{ foo["property with spaces"] }}
{{ foo[path.to.variable] }}
```

Array items are accessed by their zero-based index and bracket notation. Dotted indexes are not allowed.

```liquid2
{{ foo[0] }}
{{ foo[path.to.variable] }}
```

A trailing path segment ending with a question mark (`?`) is a _predicate_. A predicate "queries" the value obtained by resolving the path up to that point and returns `true` or `false`. See the [predicate reference](./predicate_reference.md) for details of all built-in predicate functions.

```
{{ foo.defined? }}
{{ foo.bar.object? }}
{{ foo.bar.baz.string? }}
{{ foo.bar.baz.empty? }}
```

### Operators & Precedence

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
