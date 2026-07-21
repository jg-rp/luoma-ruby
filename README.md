# Luoma

TODO:

## TODO:

- replace :nothing with a singleton Nothing drop
- test `sort`, `sort_natural` and `sort_numeric`
- test string filters
- test static analysis
- lambda static analysis
- docs

## Notes

- There's no `{% comment %}` or `{% # %}` tag. Use `{# some comment #}` instead.
- There's no `{% doc %}` tag. Use `{# some doc comment #}` instead.
- There's no `{% liquid %}` or equivalent tag. Use compound and ternary expressions, multi assigns with the `{% assign %}` tag, and block-scoped variables with the `{% with %}` tag.
- There's no `{% unless %}` tag. Use `{% if not (...) %}` or `{% if a != b %}`.
- `{% for %}` does not accept arguments. Use the `slice` and `reverse` filters instead.
- The `slice` filter accepts `start`, `stop` and `step` arguments instead of `limit` and `offset`. `start`, `stop` and `step` can be positional or keyword and positive or negative.
- There's no `forloop` drop. Use optional index and array binding syntax: `{% for a, index, array in ... %}`.
- Strings are iterated and sliced like an array of characters.
- `{% render %}` and `{% include %}` don't accept binding or looping arguments. Use a `{% for %}` loop instead.
- There's no `empty` or `blank` objects. Use `thing.empty?` and `thing.blank?` instead.
- Filters that expect an array input do not implicitly flatten nested arrays. Use the `flatten` filter if needed.

- First-class blocks with `{% define %} ... {% enddefine%}`
- First-class expressions with `{% assign x = <lambda expr> %}`
- Type predicates
- Case tag accepts type predicates
- `{% import %}` is a cross between `{% include %}` and `{% render %}`. It requires a string argument and renders a template just for its side effects, discarding any output.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
