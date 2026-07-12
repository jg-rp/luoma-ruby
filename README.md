# Luoma

TODO: 

## TODO:

- Pass ExpressionDrop as argument to array filter

## Notes

- There's no `{% comment %}` or `{% # %}` tag. Use `{# some comment #}` instead.
- There's no `{% doc %}` tag. Use `{# some doc comment #}` instead.
- There's no `{% liquid %}` or equivalent tag. Use compound and ternary expressions, multi assigns with the `{% assign %}` tag, and block-scoped variables with the `{% with %}` tag.
- `{% for %}` does not accept arguments. Use the `slice` and `reverse` filters instead.
- The `slice` filter accepts `start`, `stop` and `step` arguments instead of `limit` and `offset`. `start`, `stop` and `step` can be positional or keyword and positive or negative.
- `forloop` does not have a `name` property.
- Strings are iterated and sliced like an array of characters.
- `{% render %}` and `{% include %}` don't accept binding or looping arguments. Use a `{% for %}` loop instead.

- First-class blocks with `{% define %} ... {% enddefine%}`
- First-class expressions with `{% assign x = <lambda expr> %}`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
