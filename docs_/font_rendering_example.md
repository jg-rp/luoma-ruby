Old:

```
{%- liquid
  assign rendered_fonts = ''

  assign primary_font = settings.type_body_font
  assign primary_font_bold = primary_font | font_modify: 'weight', 'bold'
  assign primary_font_italic = primary_font | font_modify: 'style', 'italic'
  assign primary_font_bold_italic = primary_font_bold | font_modify: 'style', 'italic'

  assign primary_font_face_id = '[primary_font_family]-[primary_font_weight]-[primary_font_style]|' | replace: '[primary_font_family]', primary_font.family | replace: '[primary_font_weight]', primary_font.weight | replace: '[primary_font_style]', primary_font.style
  assign primary_font_bold_face_id = '[primary_font_bold_family]-[primary_font_bold_weight]-[primary_font_bold_style]|' | replace: '[primary_font_bold_family]', primary_font_bold.family | replace: '[primary_font_bold_weight]', primary_font_bold.weight | replace: '[primary_font_bold_style]', primary_font_bold.style
  assign primary_font_italic_face_id = '[primary_font_italic_family]-[primary_font_italic_weight]-[primary_font_italic_style]|' | replace: '[primary_font_italic_family]', primary_font_italic.family | replace: '[primary_font_italic_weight]', primary_font_italic.weight | replace: '[primary_font_italic_style]', primary_font_italic.style
  assign primary_font_bold_italic_face_id = '[primary_font_bold_italic_family]-[primary_font_bold_italic_weight]-[primary_font_bold_italic_style]|' | replace: '[primary_font_bold_italic_family]', primary_font_bold_italic.family | replace: '[primary_font_bold_italic_weight]', primary_font_bold_italic.weight | replace: '[primary_font_bold_italic_style]', primary_font_bold_italic.style

  assign secondary_font = settings.type_subheading_font
  assign secondary_font_bold = secondary_font | font_modify: 'weight', 'bold'
  assign secondary_font_italic = secondary_font | font_modify: 'style', 'italic'
  assign secondary_font_bold_italic = secondary_font_bold | font_modify: 'style', 'italic'

  assign secondary_font_face_id = '[secondary_font_family]-[secondary_font_weight]-[secondary_font_style]|' | replace: '[secondary_font_family]', secondary_font.family | replace: '[secondary_font_weight]', secondary_font.weight | replace: '[secondary_font_style]', secondary_font.style
  assign secondary_font_bold_face_id = '[secondary_font_bold_family]-[secondary_font_bold_weight]-[secondary_font_bold_style]|' | replace: '[secondary_font_bold_family]', secondary_font_bold.family | replace: '[secondary_font_bold_weight]', secondary_font_bold.weight | replace: '[secondary_font_bold_style]', secondary_font_bold.style
  assign secondary_font_italic_face_id = '[secondary_font_italic_family]-[secondary_font_italic_weight]-[secondary_font_italic_style]|' | replace: '[secondary_font_italic_family]', secondary_font_italic.family | replace: '[secondary_font_italic_weight]', secondary_font_italic.weight | replace: '[secondary_font_italic_style]', secondary_font_italic.style
  assign secondary_font_bold_italic_face_id = '[secondary_font_bold_italic_family]-[secondary_font_bold_italic_weight]-[secondary_font_bold_italic_style]|' | replace: '[secondary_font_bold_italic_family]', secondary_font_bold_italic.family | replace: '[secondary_font_bold_italic_weight]', secondary_font_bold_italic.weight | replace: '[secondary_font_bold_italic_style]', secondary_font_bold_italic.style

  assign tertiary_font = settings.type_heading_font
  assign tertiary_font_bold = tertiary_font | font_modify: 'weight', 'bold'
  assign tertiary_font_italic = tertiary_font | font_modify: 'style', 'italic'
  assign tertiary_font_bold_italic = tertiary_font_bold | font_modify: 'style', 'italic'

  assign tertiary_font_face_id = '[tertiary_font_family]-[tertiary_font_weight]-[tertiary_font_style]|' | replace: '[tertiary_font_family]', tertiary_font.family | replace: '[tertiary_font_weight]', tertiary_font.weight | replace: '[tertiary_font_style]', tertiary_font.style
  assign tertiary_font_bold_face_id = '[tertiary_font_bold_family]-[tertiary_font_bold_weight]-[tertiary_font_bold_style]|' | replace: '[tertiary_font_bold_family]', tertiary_font_bold.family | replace: '[tertiary_font_bold_weight]', tertiary_font_bold.weight | replace: '[tertiary_font_bold_style]', tertiary_font_bold.style
  assign tertiary_font_italic_face_id = '[tertiary_font_italic_family]-[tertiary_font_italic_weight]-[tertiary_font_italic_style]|' | replace: '[tertiary_font_italic_family]', tertiary_font_italic.family | replace: '[tertiary_font_italic_weight]', tertiary_font_italic.weight | replace: '[tertiary_font_italic_style]', tertiary_font_italic.style
  assign tertiary_font_bold_italic_face_id = '[tertiary_font_bold_italic_family]-[tertiary_font_bold_italic_weight]-[tertiary_font_bold_italic_style]|' | replace: '[tertiary_font_bold_italic_family]', tertiary_font_bold_italic.family | replace: '[tertiary_font_bold_italic_weight]', tertiary_font_bold_italic.weight | replace: '[tertiary_font_bold_italic_style]', tertiary_font_bold_italic.style

  assign accent_font = settings.type_accent_font
  assign accent_font_bold = accent_font | font_modify: 'weight', 'bold'
  assign accent_font_italic = accent_font | font_modify: 'style', 'italic'
  assign accent_font_bold_italic = accent_font_bold | font_modify: 'style', 'italic'

  assign accent_font_face_id = '[accent_font_family]-[accent_font_weight]-[accent_font_style]|' | replace: '[accent_font_family]', accent_font.family | replace: '[accent_font_weight]', accent_font.weight | replace: '[accent_font_style]', accent_font.style
  assign accent_font_bold_face_id = '[accent_font_bold_family]-[accent_font_bold_weight]-[accent_font_bold_style]|' | replace: '[accent_font_bold_family]', accent_font_bold.family | replace: '[accent_font_bold_weight]', accent_font_bold.weight | replace: '[accent_font_bold_style]', accent_font_bold.style
  assign accent_font_italic_face_id = '[accent_font_italic_family]-[accent_font_italic_weight]-[accent_font_italic_style]|' | replace: '[accent_font_italic_family]', accent_font_italic.family | replace: '[accent_font_italic_weight]', accent_font_italic.weight | replace: '[accent_font_italic_style]', accent_font_italic.style
  assign accent_font_bold_italic_face_id = '[accent_font_bold_italic_family]-[accent_font_bold_italic_weight]-[accent_font_bold_italic_style]|' | replace: '[accent_font_bold_italic_family]', accent_font_bold_italic.family | replace: '[accent_font_bold_italic_weight]', accent_font_bold_italic.weight | replace: '[accent_font_bold_italic_style]', accent_font_bold_italic.style

  unless rendered_fonts contains primary_font_face_id
    echo primary_font | font_face: font_display: 'swap'
    assign rendered_fonts = rendered_fonts | append: primary_font_face_id
  endunless

  unless rendered_fonts contains primary_font_bold_face_id
    echo primary_font_bold | font_face: font_display: 'swap'
    assign rendered_fonts = rendered_fonts | append: primary_font_bold_face_id
  endunless

  unless rendered_fonts contains primary_font_italic_face_id
    echo primary_font_italic | font_face: font_display: 'swap'
    assign rendered_fonts = rendered_fonts | append: primary_font_italic_face_id
  endunless

  unless rendered_fonts contains primary_font_bold_italic_face_id
    echo primary_font_bold_italic | font_face: font_display: 'swap'
    assign rendered_fonts = rendered_fonts | append: primary_font_bold_italic_face_id
  endunless

  unless rendered_fonts contains secondary_font_face_id
    echo secondary_font | font_face: font_display: 'swap'
    assign rendered_fonts = rendered_fonts | append: secondary_font_face_id
  endunless

  unless rendered_fonts contains secondary_font_bold_face_id
    echo secondary_font_bold | font_face: font_display: 'swap'
    assign rendered_fonts = rendered_fonts | append: secondary_font_bold_face_id
  endunless

  unless rendered_fonts contains secondary_font_italic_face_id
    echo secondary_font_italic | font_face: font_display: 'swap'
    assign rendered_fonts = rendered_fonts | append: secondary_font_italic_face_id
  endunless

  unless rendered_fonts contains secondary_font_bold_italic_face_id
    echo secondary_font_bold_italic | font_face: font_display: 'swap'
    assign rendered_fonts = rendered_fonts | append: secondary_font_bold_italic_face_id
  endunless

  unless rendered_fonts contains tertiary_font_face_id
    echo tertiary_font | font_face: font_display: 'swap'
    assign rendered_fonts = rendered_fonts | append: tertiary_font_face_id
  endunless

  unless rendered_fonts contains tertiary_font_bold_face_id
    echo tertiary_font_bold | font_face: font_display: 'swap'
    assign rendered_fonts = rendered_fonts | append: tertiary_font_bold_face_id
  endunless

  unless rendered_fonts contains tertiary_font_italic_face_id
    echo tertiary_font_italic | font_face: font_display: 'swap'
    assign rendered_fonts = rendered_fonts | append: tertiary_font_italic_face_id
  endunless

  unless rendered_fonts contains tertiary_font_bold_italic_face_id
    echo tertiary_font_bold_italic | font_face: font_display: 'swap'
    assign rendered_fonts = rendered_fonts | append: tertiary_font_bold_italic_face_id
  endunless

  unless rendered_fonts contains accent_font_face_id
    echo accent_font | font_face: font_display: 'swap'
    assign rendered_fonts = rendered_fonts | append: accent_font_face_id
  endunless

  unless rendered_fonts contains accent_font_bold_face_id
    echo accent_font_bold | font_face: font_display: 'swap'
    assign rendered_fonts = rendered_fonts | append: accent_font_bold_face_id
  endunless

  unless rendered_fonts contains accent_font_italic_face_id
    echo accent_font_italic | font_face: font_display: 'swap'
    assign rendered_fonts = rendered_fonts | append: accent_font_italic_face_id
  endunless

  unless rendered_fonts contains accent_font_bold_italic_face_id
    echo accent_font_bold_italic | font_face: font_display: 'swap'
    assign rendered_fonts = rendered_fonts | append: accent_font_bold_italic_face_id
  endunless
%}
```

New:

```title="font_utils"
{% assign
  bold        = f -> (f | font_modify: 'weight', 'bold'),
  italic      = f -> (f | font_modify: 'style', 'italic'),
  bold_italic = f -> (f | font_modify: 'weight', 'bold' | font_modify: 'style', 'italic')
%}
```

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
