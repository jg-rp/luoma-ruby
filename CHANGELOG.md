## [0.3.0] - 2026-08-04

- Added the `escape_js` filter ([docs](https://jg-rp.github.io/luoma-ruby/filter_reference/#escape_js)).
- Removed the `sort_natural` filter. Use `a | sort: i -> (i | upcase)` instead.

## [0.2.0] - 2026-07-29

- Added the `take` filter. `a | take: 5` is equivalent to `a | slice: stop=6`.

## [0.1.0] - 2026-07-29

- Initial release
