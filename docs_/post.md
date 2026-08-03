# A unified expression language for Liquid-style templates

I [previously wrote](https://www.reddit.com/r/ruby/comments/1od9y8a/i_rewrote_liquid_from_scratch_and_added_features/) about adding new syntax and features to Liquid. Since then I’ve been working on a unified, composable expression language ([spec](https://jg-rp.github.io/template-expression-spec/), [grammar](https://jg-rp.github.io/template-expression-spec/#appendix-b.-collected-peg-grammar), [GitHub](https://github.com/jg-rp/template-expression-spec)), and luoma-ruby ([GitHub](https://github.com/jg-rp/luoma-ruby), [docs](https://jg-rp.github.io/luoma-ruby/), [RubyGems](https://rubygems.org/gems/luoma)), a reference template engine that implements it.

The expression language is "unified" in the sense that all operators are valid in all contexts under a single precedence hierarchy. Meaning, for example, that we can apply filters in `{% for %}` tag expressions:

```
{% for x in y | compact | take: 5 %} ... {% endfor %}
```

And use logical operators (`not`, `and`, `or`) in `{% assign %}` tag expressions:

```
{% assign a = not b.c.null? %}
```

Or in filter arguments:

```
{{ x | join: (y or "\n") }}
```

Having a more expressive expression language introduces new idioms that are not possible in the current version of Liquid. This allows Luoma to discard some Liquid "workarounds" in favour of a smaller library of standard tags and drops.

For example, Luoma does not include a `{% liquid %}` tag or an equivalent tag for newline terminated expressions. Instead we use multi-assigning `{% assign %}` tags, `{% with %}` for defining temporary block-scoped variables, short circuiting logical operators, ternary expressions and lambda expressions.

```
{%- with
  classes = [
    "product-card",
    "product-card--sold-out" if not product.available,
    "product-card--featured" if product.featured,
    "product-card--new" if product.tags contains "new",
  ]
-%}
  <div class="{{ classes | compact | join }}">
    <h2>{{ product.title }}</h2>
  </div>
{% endwith %}
```

## First-class blocks and expressions

When it comes to template composition, both template inheritance and React-style props and slots can be good options, but Luoma includes just one new template composition primitive, `{% define %}`. `{% define %}` is like a deferred version of `{% capture %}`. The resulting `BlockDrop` captures nothing about where it was defined (it's not a closure). It is rendered in the scope where it is output or coerced to a string.

TODO: Example

Expressions are first-class too. Using lambda syntax we can save an expression for later and apply it like a user-defined filter.

```
{# font_utils.luoma #}

{% assign
  bold        = f -> (f | font_modify: 'weight', 'bold'),
  italic      = f -> (f | font_modify: 'style', 'italic'),
  bold_italic = f -> (f | font_modify: 'weight', 'bold' | font_modify: 'style', 'italic')
%}
```

Then

```
{%- import "font_utils" -%}

{% with
  font_types = [
    settings.type_body_font,
    settings.type_subheading_font,
    settings.type_heading_font,
    settings.type_accent_font
  ],

  font_faces = font_types
    | flat_map : f -> [f, (f | bold), (f | italic), (f | bold_italic)]
    | uniq     : f -> '${f.family}-${f.weight}-${f.style}'
    | map      : f -> (f | font_face: font_display: 'swap')
%}
  {{- font_faces | join: "\n\n" -}}
{% endwith %}
```

## Closing thoughts

As I said in my previous post, I understand why Liquid is the way it is, and I'm sure Shopify have explored many of these ideas before. In an ideal world I’d love to see Shopify adopt an opt-in upgrade path for theme developers to use new, backwards-incompatible template features with an explicit version scheme.

Hopefully Luoma provides some inspiration and/or ideas that might someday make it into a future version of Liquid.
