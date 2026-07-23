Old:

Start at zero, post output increment

```
{% increment foo %}
{% increment foo %}
{{ foo }}
```

```title="output"
0
1
2
```

Start at zero, pre output decrement

```
{% decrement foo %}
{% decrement foo %}
{{ foo }}
```

```title="output"
-1
-2
-2
```

New:

```
{% assign foo = 0 -%}
{{ foo }}
{% assign foo = foo + 1 -%}
{{ foo }}
{% assign foo = foo + 1 -%}
{{ foo }}
```

```
{% assign foo = 0 %}
{% assign foo = foo - 1 -%}
{{ foo }}
{% assign foo = foo - 1 -%}
{{ foo }}
{{ foo }}
```
