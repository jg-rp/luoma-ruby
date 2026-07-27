From Horizon `_header-logo.liquid`:

```
{% liquid
  assign logo_width = settings.logo_height | times: settings.logo.aspect_ratio | ceil
  assign logo_width_mobile = settings.logo_height_mobile | times: settings.logo.aspect_ratio | ceil
  assign inverse_logo_width = settings.logo_height | times: inverse_logo.aspect_ratio | ceil
  assign inverse_logo_width_mobile = settings.logo_height_mobile | times: inverse_logo.aspect_ratio | ceil
  assign logo_style = '--header-logo-image-width: ' | append: logo_width | append: 'px;' | append: '--header-logo-image-width-mobile: ' | append: logo_width_mobile | append: 'px; --header-logo-image-height: ' | append: settings.logo_height | append: 'px; --header-logo-image-height-mobile: ' | append: settings.logo_height_mobile | append: 'px;'
  assign inverse_logo_style = '--header-logo-image-width: ' | append: inverse_logo_width | append: 'px;' | append: '--header-logo-image-width-mobile: ' | append: inverse_logo_width_mobile | append: 'px; --header-logo-image-height: ' | append: settings.logo_height | append: 'px; --header-logo-image-height-mobile: ' | append: settings.logo_height_mobile | append: 'px;'
%}
```

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
