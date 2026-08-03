---
title: Markup
---

# Luoma

Luoma is a template language, where source text (the template) contains placeholders for variables, conditional expressions for including or excluding blocks of text, and loops for repeating blocks of text. Plus other syntax for manipulating variables and combining multiple templates into a single output.

Output text is the result of _rendering_ a template given some data model. It is that data model that provides the variables referenced in a template's expressions.

Luoma is commonly used with HTML or Markdown, but can be used with any text-based content.

## Markup

Luoma markup is delimited by double braces for [output statements](#output) (`{{ ... }}`), braces with percents for [tags](#tags) (`{% ... %}`), and braces with hashes for [comments](#comments) (`{# ... #}`).

Everything else outside these markup delimiters is plain content and, with the exception of [whitespace control](#whitespace-control), will be output unchanged.

### Output

`{{ site_description }}` and `{{ item.title | capitalize }}` are examples of [output statements](./tag_reference.md#output). Expressions surrounded by double curly braces, `{{` and `}}`, will be evaluated and the result inserted into the output text.

In this example `Hello, ` and `!` are plain content, and `you` is a [variable](./expressions.md#variables-and-property-access). At render time, `{{ you }}` will be replaced by the value pointed to by `you`.

```liquid2 title="Template"
Hello, {{ you }}!
```

If `you` is assigned the value `"World"`, we'd get the following output.

```title="Output"
Hello, World!
```

### Filters

`capitalize` in `{{ item.title | capitalize }}` and `ceil` in `{{ item.price | ceil }}` are examples of [filters](./filter_reference.md). A filter transforms the value to the left of the pipe operator (`|`) according to the filter name and arguments on the right. We can chain multiple filters together to form a pipeline of transformations.

```
{{ "Hello, World!" | upcase }}
{{ "Hello, World!" | split: ', ' | first | upcase }}

{% for x in (1..10) | take: 5 | reverse ~%}
  - {{ x }}
{% endfor %}
```

```title="Output"
HELLO, WORLD!
HELLO

  - 5
  - 4
  - 3
  - 2
  - 1
```

### Tags

`{% if site_description %}`, `{% endif %}` and `{% assign items_size = items | size %}` are examples of [tags](./tag_reference.md). After the start tag delimiter (`{%`) there must be a tag name. Everything up to the closing tag delimiter (`%}`) is the tags's expression.

Not all tags accept an expression, but all tag must have a name.

Together `{% if site_description %}` and `{% endif %}` form a _block tag_. Block tags have an opening tag, some markup in between, and an end tag. In the case of the [`if tag`](./tag_reference.md#if), the block is only rendered if the tag's expression evaluates to a truthy value.

```liquid2
{% if not site_description.empty? %}
  {{ site_description }}
{% end %}
```

`{% assign items_size = items | size %}` is an _inline tag_. It does not have a matching end tag and it does not output anything. Although some inline tags do produce an output.

### Comments

Text surrounded by `{#` and `#}` is a comments. Comment are ignored at render time and produce no output. Additional `#`'s can be added to comment out blocks of markup that already contain comments, as long as hashes are balanced.

```liquid2
{##
 # This is a doc comment
 # to be read by a documentation generator.
 ##}

{## comment this out for now
{% for x in y %}
  {# x could be empty #}
  {{ x | default: TODO }}
{% endfor %}
##}
```

### Whitespace control

By default, all whitespace immediately before and after a tag is preserved. This can result in a lot of unwanted whitespace.

```liquid2
<ul>
{% for x in (1..4) %}
  <li>{{ x }}</li>
{% endfor %}
</ul>
```

```html title="Output"
<ul>
  <li>1</li>

  <li>2</li>

  <li>3</li>

  <li>4</li>
</ul>
```

We can control whitespace inclusion by adding `-`, `~` or `+` immediately after an opening markup delimiter or immediately before a closing delimiter.

By default, `-` removes all whitespace before an opening delimiter or after a closing delimiter. `~` removes newlines and carriage returns, but preserves indentation, and `+` ensures all whitespace is kept, which is helpful when automatic whitespace trimming is enabled.

```liquid2
<ul>
{% for x in (1..4) ~%}
  <li>{{ x }}</li>
{% endfor -%}
</ul>
```

```html title="Output"
<ul>
  <li>1</li>
  <li>2</li>
  <li>3</li>
  <li>4</li>
</ul>
```
