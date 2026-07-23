```liquid2 title="font_utils"
{% assign
  font_id     = f -> '${f.family}-${f.weight}-${f.style}',
  bold        = f -> f | font_modify: 'weight', 'bold',
  italic      = f -> f | font_modify: 'style', 'italic',
  bold_italic = f -> f | font_modify: 'weight', 'bold' | font_modify: 'style', 'italic',
%}
```

```liquid2
{% import "font_utils" %}

{% with
  font_types = [
    settings.type_body_font,
    settings.type_subheading_font,
    settings.type_heading_font,
    settings.type_accent_font
  ],

  fonts = font_types
    | flat_map: f -> [f, (f | bold), (f | italic), (f | bold_italic)]
    | uniq:     font_id
    | map:      f -> (f | font_face: font_display: 'swap')
%}
  {{ fonts | join: "\n" }}
{% endwith %}
```