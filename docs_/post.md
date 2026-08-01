# A unified expression language for Liquid-style templates

I [previously wrote](https://www.reddit.com/r/ruby/comments/1od9y8a/i_rewrote_liquid_from_scratch_and_added_features/) about adding new syntax and features to Liquid. Since then I’ve been working on a unified, composable expression language ([spec](https://jg-rp.github.io/template-expression-spec/), [grammar](https://jg-rp.github.io/template-expression-spec/#appendix-b.-collected-peg-grammar), [GitHub](https://github.com/jg-rp/template-expression-spec)), and luoma-ruby ([GitHub](https://github.com/jg-rp/luoma-ruby), [docs](https://jg-rp.github.io/luoma-ruby/), [RubyGems](https://rubygems.org/gems/luoma)), a reference template engine that implements it.

The expression language is "unified" in the sense that all operators are valid in all contexts under a single precedence hierarchy. Meaning, for example, that we can apply filters in `{% for %}` tag expressions.

```
{% for x in y | slice: 2, 8 | compact %} ... {% endfor %}
```

Or

```
{% for item, index, array in y | where: (a) -> (a.b.c > 2 or a.d) | take: 5 %}
  ...
{% endfor %}
```

Or

```
{% with
  logo_width = settings.logo_height * settings.logo.aspect_ratio | ceil,
  logo_width_mobile = settings.logo_height_mobile * settings.logo.aspect_ratio | ceil,
  inverse_logo_width = settings.logo_height * inverse_logo.aspect_ratio | ceil,
  inverse_logo_width_mobile = settings.logo_height_mobile * inverse_logo.aspect_ratio | ceil,

  logo_styles = [
    '--header-logo-image-width: ${logo_width}px;',
    '--header-logo-image-width-mobile: ${logo_width_mobile}px;',
    '--header-logo-image-height: ${settings.logo_height}px;',
    '--header-logo-image-height-mobile: ${settings.logo_height_mobile}px;',
  ],

  inverse_logo_styles = [
    '--header-logo-image-width: ${inverse_logo_width}px;',
    '--header-logo-image-width-mobile: ${inverse_logo_width_mobile}px;',
    '--header-logo-image-height: ${settings.logo_height}px;',
    '--header-logo-image-height-mobile: ${settings.logo_height_mobile}px;',
  ]
%}
  {% assign
    logo_style = logo_styles | join,
    inverse_logo_style = inverse_logo_styles | join,
  %}
{% endwith %}
```

Having a more expressive expression language introduces new idioms that are not possible in the current version of Liquid. This allows Luoma to discard some Liquid "workarounds" in favour of a smaller library of standard tags and drops.

For example, Luoma does not include a `{% liquid %}` tag or any equivalent tag for newline terminated expressions. Instead we use multi-assigning `{% assign %}` tags, `{% with %}` for defining temporary block-scoped variables, short circuiting logical operators, ternary and lambda expressions.

## First-class blocks and expressions

While both template inheritance and React-style props and slots can be good options, Luoma includes just one new template composition primitive, `{% define %}`. `{% define %}` is like a deferred version of `{% capture %}`. The resulting `BlockDrop` captures nothing about where it was defined (it's not a closure). It is rendered in the scope where it is output or coerced to a string.

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

Note that the expression language is formally defined and Luoma - which happens to implement the expression language - is left as a reference implementation. Markup delimiters, tags, filters and the surrounding template engine can vary in lots of equally valid ways, depending on the task at hand.

As I said in my previous post, I understand why Liquid is the way it is, and I imagine Shopify have explored many of these ideas before, only to be held back by integration practicalities and shifting priorities.

In an ideal world I’d love to see Shopify adopt an opt-in upgrade path for theme developers to use new, backwards-incompatible template features with an explicit version scheme.

Hopefully Luoma provides some inspiration and ideas that might someday make it into Liquid.
