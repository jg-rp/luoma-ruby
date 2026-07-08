# Luoma

TODO: 

## Notes

- `{% for %}` does not accept arguments. Use the `slice` and `reverse` filters instead.
- The `slice` filter accepts `start`, `stop` and `step` arguments instead of `limit` and `offset`. `start`, `stop` and `step` can be positional or keyword and positive or negative.
- `forloop` does not have a `name` property.
- Strings are iterated and sliced like an array of characters.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
