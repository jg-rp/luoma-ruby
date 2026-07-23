<h1 align="center">Luoma - Ruby</h1>

<p align="center">A modern template engine for Ruby.</p>

<p align="center">
  <a href="https://github.com/jg-rp/luoma-ruby/blob/main/LICENSE.txt">
    <img alt="GitHub License" src="https://img.shields.io/github/license/jg-rp/luoma-ruby?style=flat-square">
  </a>
  <a href="https://github.com/jg-rp/luoma-ruby/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/jg-rp/luoma-ruby/main.yml?branch=main&label=tests&style=flat-square" alt="Tests">
  </a>
  <br>
  <a href="https://rubygems.org/gems/luoma">
    <img alt="Gem Version" src="https://img.shields.io/gem/v/luoma?style=flat-square">
  </a>
  <a href="https://github.com/jg-rp/luoma-ruby">
    <img alt="Static Badge" src="https://img.shields.io/badge/Ruby-3.1%20%7C%203.2%20%7C%203.3%20%7C%203.4-CC342D?style=flat-square">
  </a>
</p>

**Table of Contents**

- [Install](#install)
- [Example](#example)
- [Links](#links)
- [License](#license)

## Install

Add `'luoma'` to your Gemfile:

```
gem 'luoma', '~> 0.1.0'
```

Or

```
gem install luoma
```

Or

```
bundle add luoma
```

## Example

```ruby
require "luoma"

template = Luoma.parse("Hello, {{ you }}!")
puts template.render("you" => "World")  # Hello, World!
puts template.render("you" => "Liquid")  # Hello, Liquid!
```

## Links

- Documentation: https://jg-rp.github.io/luoma/
- Change log: https://github.com/jg-rp/luoma-ruby/blob/main/CHANGELOG.md
- RubyGems: https://rubygems.org/gems/luoma
- Source code: https://github.com/jg-rp/luoma-ruby
- Issue tracker: https://github.com/jg-rp/luoma-ruby/issues

## TODO:

- replace :nothing with a singleton Nothing drop
- finish testing string filters
- `{% define %}` tag static analysis. We need to analyze the block when it is rendered, keyed on the current static scope state.
- Store and report the "call site" of defined blocks and partial templates.
- docs
- test auto escape
- Update string filters to handle safe strings

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
