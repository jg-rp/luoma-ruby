---
hide:
  - navigation
---

# Built-in tags

## Comments

TODO

## Output

```title="Syntax"
{{ <expression> }}
```

An expression surrounded by double curly braces (`{{` and `}}`) is an _output statement_. When rendered, the expression will be evaluated and the result written to the output stream.

In this example the expression is the variable `you` - which will be resolved to a value and the value's string representation will be written to the output stream - but output statements can contain any expression.

```liquid2
Hello, {{ you }}!
```

## assign

```title="Syntax"
{% assign <identifier> = <expression> [, <identifier> = <expression> ...] %}
```

The `assign` tag binds the result of evaluating an expression to a name, creating or updating a variable.

```liquid2
{% assign foo = "bar" %}
{% assign foo = 42 %}
```

A single `assign` tag can define multiple variables, separated by commas. Earlier bindings are immediately available in later expressions.

```liquid2
{% assign
  a = 1,
  b = a + 1
%}
```

## capture

```title="Syntax"
{% capture <identifier> %} <markup> {% endcapture %}
```

The `capture` tag renders a block of markup to a string variable instead of writing it directly to the output stream.

```liquid2
{% assign first_name = "Sam" %}
{% assign points = 120 %}

{% capture message %}
Hello {{ first_name }}!
You have {{ points }} reward points.
{% endcapture %}

<p>{{ message }}</p>
```

```title="Output"
<p>Hello Sam!
You have 120 reward points.</p>
```

See also the [`define`](#define) tag.

## case

```title="Syntax"
{% case <expression> %}
  [ {% when <expression | predicate> [, <expression | predicate>] %} <markup> ] ...
  [ {% else %} <markup> ]
{% endcase %}
```

The `case` tag provides a multi-way conditional. It compares the result of a single expression against the result of one or more candidate expressions, and renders the block following the first matching `{% when %}` tag. If no branch matches, the optional `{% else %}` branch is rendered.

```liquid2
{% assign day = "Monday" %}

{% case day %}
  {% when "Monday" %}
    Start of the work week!
  {% when "Friday" %}
    It's almost the weekend!
  {% when "Saturday" or "Sunday" %}
    Enjoy your weekend!
  {% else %}
    Just another weekday.
{% endcase %}
```

`when` tags also understand _bare predicates_, like `.defined?` and `.empty?` in place of a standard expression.

```liquid2
{% case items %}
  {% when empty? %}
    No items.
  {% else %}
    {{ items | size }} items.
{% endcase %}
```

## define

```title="Syntax"
{% define <identifier> [ visibility: ("public" | "private") ] %} <markup> {% enddefine %}
```

The `define` tag captures a block of markup for later rendering. `define` captures nothing about the scope in which it rendered. Defined blocks are rendered in the scope in which they are output or coerced to a string.

```liquid2
{% assign name = "Alice" %}

{% define greeting %}
Hello {{ name }}!
{% enddefine %}

{% assign name = "Bob" %}

{{ greeting }}
{{ greeting | upcase }}
```

```title="Output"
Hello Bob!
HELLO BOB!
```

`define` can be though of as a deferred [`capture`](#capture). See also [`import`](#import).

## for

```title="Syntax"
{% for <identifier> [, identifier [, identifier]] in <expression> %}
  <markup>
  [ {% else %} <markup> ]
{% endfor %}
```

The `for` tag renders its block once for each item in an iterable object, like an array/list or mapping/dict/hash. If the iterable is empty and an `else` block given, it will be rendered instead.

```liquid2
{% for product in collection %}
    - {{ product.title }}
{% else %}
    No products available
{% endfor %}
```

Range expression are often used with the `for` tag to loop over increasing integers.

```liquid2
{% for i in (1..4) %}
    {{ i }}
{% endfor %}
```

### break

You can exit a loop early using the `break` tag.

```liquid2
{% for product in collection.products %}
    {% if product.title == "Shirt" %}
        {% break %}
    {% endif %}
    - {{ product.title }}
{% endfor %}
```

### continue

You can skip all or part of a loop iteration with the `continue` tag.

```liquid2
{% for product in collection.products %}
    {% if product.title == "Shirt" %}
        {% continue %}
    {% endif %}
    - {{ product.title }}
{% endfor %}
```

## if

```
{% if <expression> %}
  <markup>
  [ {% elsif <expression> %} <markup> [ {% elsif <expression> %} ... ]]
  [ {% else %} <markup> ... ]
{% endif %}
```

The `if` tag conditionally renders its block if its expression evaluates to be truthy. Any number of `elsif` blocks can be given to add alternative conditions, and an `else` block is used as a default if no preceding conditions were truthy.

```liquid2
{% if product.title == "OK Hat" %}
  This hat is OK.
{% elsif product.title == "Rubbish Tie" %}
  This tie is rubbish.
{% else %}
  Not sure what this is.
{% endif %}
```

## import

```title="Syntax"
{% import <string> [ as <identifier>] %}
```

The `import` tag loads and renders a named template for its side effects, discarding its output. `import` is used to bring variables (including blocks defined with the [`define` tag](#define)) into scope.

```liquid2
{% import button_utils as buttons %}
```

## include

```title="Syntax"
{% include <template name>
    [[,] <identifier>: <expression> [, [<identifier>: <expression> ... ]]]
%}
```

The `include` tag loads and renders a named template, inserting the resulting text in its place. The name of the template to include can be a string literal or a variable resolving to a string. When rendered, the included template will share the same scope as the current template.

```liquid2
{% include "snippets/header.html" %}
```

### Keyword arguments

Additional keyword arguments given to the `include` tag will be added to the included template's scope, then go out of scope after the included template has been rendered.

```liquid2
{% include "partial_template" greeting: "Hello", num: 3, skip: 2 %}
```

## raw

```
{% raw %} <text> {% endraw %}
```

Any text between `{% raw %}` and `{% endraw %}` will not be interpreted as Liquid markup, but output as plain text instead.

```liquid2
{% raw %}
  This will be rendered {{verbatim}}, with the curly brackets.
{% endraw %}
```

## render

```title="Syntax"
{% render <string>
    [[,] <identifier>: <expression> [, [<identifier>: <expression> ... ]]]
%}
```

The `render` tag loads and renders a named template, inserting the resulting text in its place. The name of the template to include **must** be a string literal. When rendered, the included template will have its onw scope, without variables define in the calling template.

```liquid2
{% render "snippets/header.html" %}
```

### Keyword arguments

Additional keyword arguments given to the `render` tag will be added to the rendered template's scope, then go out of scope after the it has been rendered.

```liquid2
{% render "partial_template" greeting: "Hello", num: 3, skip: 2 %}
```

## with

TODO
