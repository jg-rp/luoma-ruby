Old:

Shopify's Horizon theme does this and more for 8 different fonts, each of which has regular, bold, italic and bold italic versions.

Note that the trailing `|` is used to build a long pipe-separated string of fields later in the template. An approach that is not necessary when you have array literals.

```
{%- liquid
  assign secondary_font = settings.type_subheading_font

  assign secondary_font_face_id = '[secondary_font_family]-[secondary_font_weight]-[secondary_font_style]|'
    | replace: '[secondary_font_family]', secondary_font.family
    | replace: '[secondary_font_weight]', secondary_font.weight
    | replace: '[secondary_font_style]', secondary_font.style
%}
```

New:

```
{% assign
  secondary_font = settings.type_subheading_font
  secondary_font_face_id = '${secondary_font.family}-${secondary_font.weight}-${secondary_font.style}'
%}
```

Or:

```
{% with
  font = settings.type_subheading_font,
  items = [font.family, font.weight, font.style]
%}
  {% assign secondary_font_face_id = items | join: "-" %}
{% endwith %}
```

Or:

```
{% with
  font_id = f -> '${f.family}-${f.weight}-${f.style}',
  bold = f -> | font_modify: 'weight', 'bold',
  italic = f -> | font_modify: 'style', 'italic',
  bold_italic = f -> | font_modify: 'weight', 'bold' | font_modify: 'style', 'italic',
  base_fonts = [primary_font, secondary_font, tertiary_font, accent_font],
  fonts = base_fonts | flat_map: f -> [f | bold, f | italic, f | bold_italic],
  items = fonts | map: f -> {"font": f, "id": f | font_id},
%}
  {% for item in items | uniq: "id" %}
    {{ item.font | font_face: font_display: 'swap' }}
  {% endfor %}
{% endwith %}
```

Or:

```title="font_utils"
{% assign
  font_id     = f -> '${f.family}-${f.weight}-${f.style}',
  bold        = f -> f | font_modify: 'weight', 'bold',
  italic      = f -> f | font_modify: 'style', 'italic',
  bold_italic = f -> f | font_modify: 'weight', 'bold' | font_modify: 'style', 'italic',
%}
```

```
{% import "font_utils" %}

{% with
  font_types = [
    settings.type_body_font,
    settings.type_subheading_font,
    settings.type_heading_font,
    settings.type_accent_font
  ],

  fonts = font_types
    | flat_map: f -> [(f | bold), (f | italic), (f | bold_italic)],
    | map: f -> {"font": f, "id": (f | font_id)},
    | uniq: "id"
    | map: f -> (f.font | font_face: font_display: 'swap')
%}
  {{ fonts | join: "\n" }}
{% endwith %}
```
