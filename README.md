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
    <img alt="Static Badge" src="https://img.shields.io/badge/Ruby-3.3%20%7C%203.4%20%7C%204.0-CC342D?style=flat-square">
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
puts template.render("you" => "Luoma")  # Hello, Luoma!
```

## Links

- Documentation: https://jg-rp.github.io/luoma-ruby/
- Change log: https://github.com/jg-rp/luoma-ruby/blob/main/CHANGELOG.md
- RubyGems: https://rubygems.org/gems/luoma
- Source code: https://github.com/jg-rp/luoma-ruby
- Issue tracker: https://github.com/jg-rp/luoma-ruby/issues

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
