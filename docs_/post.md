# A unified expression language for Liquid-style templates

I [previously wrote](https://www.reddit.com/r/ruby/comments/1od9y8a/i_rewrote_liquid_from_scratch_and_added_features/) about adding new syntax and features to Liquid. Since then I’ve been working on a unified, composable expression language ([spec](https://jg-rp.github.io/template-expression-spec/), [grammar](https://jg-rp.github.io/template-expression-spec/#appendix-b.-collected-peg-grammar), [GitHub](https://github.com/jg-rp/template-expression-spec)), and luoma-ruby ([GitHub](https://github.com/jg-rp/luoma-ruby), [docs](https://jg-rp.github.io/luoma-ruby/), [RubyGems](https://rubygems.org/gems/luoma)), a reference template engine that implements it.

The expression language is "unified" in the sense that all operators are valid in all contexts under a single precedence hierarchy. Meaning, for example, that we can apply filters in `{% for %}` tag expressions:

```
{% for x in y | map: a -> a.b.c | reverse | take: 5 %} ... {% endfor %}
```

Or pass lambda expressions to filters inside `{% if %}` tag expressions:

```
{% if cart.items | any: i -> i.on_sale %} ... {% endif %}
```

And use logical, comparison and math operators in `{% assign %}` tag expressions:

```
{% assign a = (b * c) or 42 %}
```

Or in filter arguments:

```
{{ a | split: (b or ',') | join: (c or '#') }}
```

Expressions are first-class. Using lambda syntax we can save an expression for later and apply it like a user-defined filter, or pass it to a filter that accepts expression arguments.

(This example is a little over the top but should give you an idea of what's possible.)

First, we can define reusable font utilities in `font_utils.luoma`:

```
{% assign
  bold        = f -> (f | font_modify: 'weight', 'bold'),
  italic      = f -> (f | font_modify: 'style', 'italic'),
  bold_italic = f -> (f | font_modify: 'weight', 'bold' | font_modify: 'style', 'italic')
%}
```

Then we can import them with the `{% import %}` tag and use the `{% with %}` tag to define some temporary, block-scoped variables.

```
{%- import "font_utils" -%}

{% with
  font_types = [
    settings.type_body_font,
    settings.type_subheading_font,
    settings.type_heading_font,
    settings.type_accent_font
  ],

  enum = f -> [
    f,
    f | bold,
    f | italic,
    f | bold_italic,
  ],

  id = f -> '${f.family}-${f.weight}-${f.style}',
  face = f -> (f | font_face: font_display: 'swap'),

  font_faces = font_types
    | flat_map : enum
    | uniq     : id
    | map      : face
    | join     : "\n\n"
%}
  {{- font_faces -}}
{% endwith %}
```

Now, if you're thinking "ew, that sort of data transformation does not belong in the presentation layer", you'd be right. But in some scenarios - when the template is the only programmable layer available - data manipulation is going to happen anyway. When we have no other choice, we should be able to transform data without resorting to convoluted string manipulation workarounds.

---

While some of Luoma’s features lean towards more advanced use cases, the idea is that a unified expression language with consistent rules makes the language simpler and more predictable for everyone.

I'm sure developers at Shopify have explored some of these ideas for Liquid in the past. Hopefully Luoma provides some inspiration or ideas that might someday make it into a future version of Liquid.
