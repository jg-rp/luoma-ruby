From Horizon `header.liquid`

```
{% liquid
  assign bottom_row_blocks = ''

  if section.settings.menu_row == 'bottom'
    assign bottom_row_blocks = bottom_row_blocks | append: 'menu,'
  endif

  if section.settings.search_style != 'none'
    if section.settings.search_row == 'bottom'
      assign bottom_row_blocks = bottom_row_blocks | append: 'search,'
    endif
  endif

  if section.settings.show_country or section.settings.show_language
    if section.settings.localization_row == 'bottom'
      assign bottom_row_blocks = bottom_row_blocks | append: 'localization,'
    endif
  endif

  assign bottom_row_blocks = bottom_row_blocks | split: ',' | compact
%}
```

```
{% with settings = section.settings %}
  {% assign
    bottom_row_blocks = [
      'menu' if settings.menu_row == 'bottom',
      'search' if settings.search_style != 'none' and settings.search_row == 'bottom',
      'localization' if (settings.show_country or settings.show_language) and settings.localization_row == 'bottom',
    ] | compact
  %}
{% endwith %}
```

```
{% with
  s = section.settings,

  blocks = [
    'menu' if s.menu_row == 'bottom',
    'search' if s.search_style != 'none' and s.search_row == 'bottom',
    'localization' if (s.show_country or s.show_language) and s.localization_row == 'bottom',
  ]
%}
  {% assign bottom_row_blocks = blocks | compact %}
{% endwith %}
```
