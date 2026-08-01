# Built-in filters

!!! warning

    This page is a work in progress. Some of the information here is not accurate.

## abs

```
<number> | abs
```

Return the absolute value of a number. Works on integers, floats and string representations of integers or floats.

```liquid2
{{ -42 | abs }}
{{ 7.5 | abs }}
{{ '42.0' | abs }}
```

```plain title="output"
42
7.5
42.0
```

Given a value that can't be cast to an integer or float, the special value `Nothing` will be returned.

```liquid2
{{ 'hello' | abs }}
{{ 'hello' | abs or 0 }}
{{ ('hello' | abs) or 99 }}
```

```plain title="output"

0
```

## all

```
<array> | all
<array> | all: <string> [, <any>]
<array> | all: <lambda>
```

Return `true` if all items in the input array are truthy, or `false` otherwise.

```liquid2
{{ [true, true, true] | all }}
{{ [true, false, true] | all }}
```

```title="Output"
true
false
```

If a string argument is given, array items should be objects and the string is used as a property name to test for truthiness.

```liquid2
{% assign
  items = [
    {"title": "foo", "active": true},
    {"title": "bar", "active": false},
    {"title": "baz", "active": true},
  ]
%}

{{ items | all: "active" }}
```

```title="Output"
false
```

If the optional second argument is given, the value at the given property will be compared to the argument value instead of testing for truthiness.

```liquid2
{% assign
  items = [
    {"title": "foo", "state": 2},
    {"title": "bar", "state": 2},
    {"title": "baz", "state": 2},
  ]
%}

{{ items | all: "state", 2 }}
```

```title="Output"
true
```

Given a lambda expression as the first argument, the expression will be evaluated for each item in the input array and the result tested for truthiness.

```liquid2
{% assign
  items = [
    {"title": "foo", "state": 2},
    {"title": "bar", "state": 3},
    {"title": "baz", "state": 1},
  ]
%}

{{ items | all: (x) -> x.state < 5 }}
```

```title="Output"
true
```

## any

```
<array> | any
<array> | any: <string> [, <any>]
<array> | any: <lambda>
```

Return `true` if any of the items in the input array are truthy, or `false` if they are all falsy.

```liquid2
{{ [true, true, true] | any }}
{{ [true, false, true] | any }}
{{ [false, false, false] | any }}
```

```title="Output"
true
true
false
```

If a string argument is given, array items should be objects and the string is used as a property name to test for truthiness.

```liquid2
{% assign
  items = [
    {"title": "foo", "active": true},
    {"title": "bar", "active": false},
    {"title": "baz", "active": true},
  ]
%}

{{ items | any: "active" }}
```

```title="Output"
true
```

If the optional second argument is given, the value at the given property will be compared to the argument value instead of testing for truthiness.

```liquid2
{% assign
  items = [
    {"title": "foo", "state": 2},
    {"title": "bar", "state": 2},
    {"title": "baz", "state": 2},
  ]
%}

{{ items | any: "state", 2 }}
```

```title="Output"
true
```

Given a lambda expression as the first argument, the expression will be evaluated for each item in the input array and the result tested for truthiness.

```liquid2
{% assign
  items = [
    {"title": "foo", "state": 2},
    {"title": "bar", "state": 3},
    {"title": "baz", "state": 1},
  ]
%}

{{ items | any: (x) -> x.state < 2 }}
```

```title="Output"
true
```

## append

```
<string> | append: <string>
```

Return the input value concatenated with the argument value.

```liquid2
{{ 'Hello, ' | append: 'World!' }}
```

```plain title="output"
Hello, World!
```

If either the input value or argument are not a string, they will be coerced to a string before concatenation.

```liquid2
{% assign a_number = 7.5 -%}
{{ 42 | append: a_number }}
{{ nosuchthing | append: 'World!' }}
```

```plain title="output"
427.5
World!
```

## at_least

```
<number> | at_least: <number>
```

Return the maximum of the input value and the argument value. Both input and argument will be cast to a number if they aren't numbers already.

```liquid2
{{ -5.1 | at_least: 8 }}
{{ 8 | at_least: '5' }}
```

```plain title="output"
8
8
```

If both input value and argument can not be cast to number, the special value `Nothing` will be returned instead.

```liquid2
{{ "hello" | at_least: 2 }}
{{ "hello" | at_least: -2 }}
{{ -1 | at_least: "abc" }}
{{ ('foo' | at_least: "bar") or 42 }}
```

```plain title="output"
2
-2
-1
42
```

## at_most

```
<number> | at_most: <number>
```

Return the minimum of the input value and the argument value. Both input and argument will be cast to a number if they aren't numbers already.

```liquid2
{{ 5 | at_most: 8 }}
{{ '8' | at_most: 5 }}
```

```plain title="output"
5
5
```

If both input value and argument can not be cast to a number, the special value `Nothing` will be returned instead.

```liquid2
{{ "hello" | at_most: 2 }}
{{ "hello" | at_most: -2 }}
{{ -1 | at_most: "abc" }}
{{ ('foo' | at_most: "bar") or 42 }}
```

```plain title="output"
2
2
-1
42
```

## capitalize

```
<string> | capitalize
```

Return a copy of the input string with the first character in upper case and all other characters in lowercase.

```liquid2
{{ 'heLLO, World!' | capitalize }}
```

```plain title="output"
Hello, world!
```

If the input value is not a string, it will be converted to a string.

```liquid2
{{ 42 | capitalize }}
```

```plain title="output"
42
```

## ceil

```
<number> | ceil
```

Round the input value up to the nearest whole number. The input value will be converted to a number if it is not an integer or float.

```liquid2
{{ 5.1 | ceil }}
{{ 5.0 | ceil }}
{{ 5 | ceil }}
{{ '5.4' | ceil }}
```

```plain title="output"
6
5
5
5
```

If the input is undefined or can't be converted to a number, the special value `Nothing` is returned.

```liquid2
{{ 'hello' | ceil }}
{{ ('hello' | ceil) or 1 }}
```

```plain title="output"

1
```

## compact

```
<array> | compact
<array> | compact: <string>
<array> | compact: <lambda>
```

Return a new array containing items from the input array excluding `null` and `Nothing` values.

```liquid2
{%- assign a = [1, 2, null, nosuchthing ] -%}
{{ a | compact }}
```

```title="Output"
[1,2]
```

If a string argument is given, array items should be objects and the string is used to lookup a property of each object.

```liquid2
{%- assign
  items = [
    { "title": "foo", "id": 1 },
    { "title": null, "id": 2 },
    { "title": "baz", "id": 3 },
  ]
-%}

{{ items | compact: "title" }}
```

```title="Output"
[{"title":"foo","id":1},{"title":"baz","id":3}]
```

If a lambda expression is given, the expression is evaluated for each item in the input array. If the expression evaluates to `nil` or `Nothing`, the item is excluded from the result.

```liquid2
{%- assign
  items = [
    { "title": "foo", "id": 1 },
    { "id": null },
    { "title": null, "id": 3 },
  ]
-%}

{{ items | compact: x -> (x.title or x.id) }}
```

```title="Output"
[{"title":"foo","id":1},{"title":null,"id":3}]
```

## concat

```
<array> | concat: <array>
```

Create a new array by concatenating the input array with the argument array.

```liquid2
{%- assign
  fruits = ["apples", "oranges", "peaches"],
  vegetables = ["carrots", "turnips", "potatoes"],
-%}

{{ fruits | concat: vegetables }}
```

```title="Output"
["apples","oranges","peaches","carrots","turnips","potatoes"]
```

If the input value or argument are not array-like, they will be coerced to arrays.

```liquid2
{% assign fruits = ["apples", "oranges", "peaches"] -%}
{{ fruits | concat: "hello" }}
```

```title="Output"
["apples","oranges","peaches","h","e","l","l","o"]
```

## date

```
<string | integer> | date: <string>
```

Format a date and/or time according the the given format string. The input value will be parsed as a date/time before formatting.

```liquid2
{{ "March 14, 2016" | date: "%b %d, %y" }}
```

```plain title="output"
Mar 14, 16
```

The special `'now'` or `'today'` input values can be used to get the current timestamp. `'today'` is an alias for `'now'`. Both include time information.

```liquid2
{{ "now" | date: "%Y-%m-%d %H:%M" }}
```

```plain title="output"
2021-12-02 10:17
```

## default

```
<any> | default[: <any>[, allow_false:<bool>]]
```

Return a default value if the input is undefined, `null`, `false` or empty. Otherwise return the input value unchanged.

```liquid2
{{ 1.99 | default: 2.99 }}
{{ nosuchthing | default: 2.99 }}
{{ [] | default: [1,2,3] }}
```

```plain title="output"
1.99
2.99
[1,2,3]
```

If the optional `allow_false` argument is `true`, an input of `false` will be passed through.

```liquid2
{{ false | default: 42, allow_false: true }}
```

```plain title="output"
false
```

If no argument is given, the default value will be an empty string.

```liquid2
{{ false | default }}
```

```plain title="output"

```

## divided_by

```
<number> | divided_by: <number>
```

Divide the input number by the argument number.

```liquid2
{{ 16 | divided_by: 4 }}
{{ 5 | divided_by: 3 }}
{{ 20 | divided_by: 7 }}
{{ 16 / 4 }}
{{ 5 / 3 }}
{{ 20 / 7 }}
```

```plain title="output"
4
1.6666666666666667
2.857142857142857
4
1.6666666666666667
2.857142857142857
```

If either the input or argument are not numeric, they will be converted to an integer or float. If conversion fails or the argument is zero, the special value `Nothing` is returned.

```liquid2
{{ "20" | divided_by: "7" }}
{{ "hello" | divided_by: 2 }}
{{ ("hello" | divided_by: 2) or 0 }}
```

```plain title="output"
2.857142857142857

0
```

## downcase

```
<string> | downcase
```

Return the input string with all characters in lowercase.

```liquid2
{{ 'Hello, World!' | downcase }}
```

```plain title="output"
hello, world!
```

If the input is not a string, it will be converted to a string before forcing characters to lowercase.

```liquid2
{{ 5 | downcase }}
```

```plain title="output"
5
```

## escape

```
<string> | escape
```

Escape special characters in a string for safe use in HTML.

This filter replaces the characters `&`, `<`, `>`, `'`, and `"` with their corresponding HTML-safe sequences:

- `&` -> `&amp;`
- `<` -> `&lt;`
- `>` -> `&gt;`
- `'` -> `&#39;`
- `"` -> `&#34;`

This helps prevent HTML injection when rendering untrusted content in HTML element bodies or attributes.

!!! warning

    This filter does **not** make strings safe for use in JavaScript, including in `<script>` blocks, inline event handler attributes (e.g. `onerror`), or other JavaScript contexts. For those cases, use the [`escape_js`](#escape_js) filter instead.

```liquid2
{{ "Have you read 'James & the Giant Peach'?" | escape }}
```

```plain title="output"
Have you read &#39;James &amp; the Giant Peach&#39;?
```

## escape_js

```
<string> | escape_js
```

Escape characters for safe use in JavaScript string literals.

This filter escapes a string for embedding inside **JavaScript string literals**, using either single or double quotes (e.g. `'...'` or `"..."`). It replaces control characters and potentially dangerous symbols with their corresponding Unicode escape sequences.

Escaped characters include:

- ASCII control characters (U+0000 to U+001F)
- Characters like quotes, angle brackets, ampersands, equals signs - Line/paragraph separators (U+2028, U+2029)

!!! warning

    This filter does **not** make strings safe for use in JavaScript template literals (backtick strings), or in raw JavaScript expressions. Use it only when placing data inside quoted JS strings within inline `<script>` blocks or event handlers.

    **Recommended alternatives:**

    - Pass data using HTML `data-*` attributes and read them in JS via `element.dataset`.
    - For structured data, prefer a JSON-serialization approach using a JSON filter.

```liquid2
{% assign some_string = "<script>alert('x')</script>" %}
<img src="" onerror="{{ some_string | escape_js }}" />
```

```plain title="output"
<img src="" onerror="\u003Cscript\u003Ealert(\u0027x\u0027)\u003C/script\u003E" />
```

## escape_once

```
<string> | escape_once
```

Escape a string for safe use in HTML while avoiding double-escaping existing entities.

Converts characters like `&`, `<`, and `>` to their HTML-safe sequences, but leaves existing HTML entities untouched (e.g., `&amp;` stays `&amp;`).

This is useful when escaping content that may already be partially escaped.

See the [`escape`](#escape) filter for details and limitations.

```liquid2
{{ "Have you read 'James &amp; the Giant Peach'?" | escape_once }}
```

```plain title="output"
Have you read &#39;James &amp; the Giant Peach&#39;?
```

## find

```
<array> | find: <string>[, <any>]
<array> | find: <lambda>
```

Find and return the first item in the input array matching the argument, or `null` if no items match.

Given a string argument and a value, array items should be objects and the first object with a property matching the value will be returned. In this example we select the first page in the "Programming" category.

```liquid2
{%- assign
  pages = [
    {
      "id": 1,
      "title": "Introduction to Cooking",
      "category": "Cooking",
      "tags": ["recipes", "beginner", "cooking techniques"]
    },
    {
      "id": 2,
      "title": "Top 10 Travel Destinations in Europe",
      "category": "Travel",
      "tags": ["Europe", "destinations", "travel tips"]
    },
    {
      "id": 3,
      "title": "Mastering JavaScript",
      "category": "Programming",
      "tags": ["JavaScript", "web development", "coding"]
    }
  ],

  page = pages | find: 'category', 'Programming'
-%}

{{ page.title }}
```

```plain title="output"
Mastering JavaScript
```

Alternatively we can pass a lambda expression. When the expression is applied to each array item, the first item that evaluates to `true` will be returned.

```liquid2
{# ...continued from above #}

{{ (pages | find: page -> (page.category == 'Programming')).title }}
```

```plain title="output"
Mastering JavaScript
```

## find_index

```
<array> | find_index: <string>[, <any>]
<array> | find_index: <lambda>
```

Return the index of the first item in the input array matching the argument, or `null` if no items match.

Given a string argument and a value, array items should be objects and the index of the first object with a property matching the value will be returned. In this example we find the index for the first page in the "Programming" category.

```liquid2
{%- assign
  pages = [
    {
      "id": 1,
      "title": "Introduction to Cooking",
      "category": "Cooking",
      "tags": ["recipes", "beginner", "cooking techniques"]
    },
    {
      "id": 2,
      "title": "Top 10 Travel Destinations in Europe",
      "category": "Travel",
      "tags": ["Europe", "destinations", "travel tips"]
    },
    {
      "id": 3,
      "title": "Mastering JavaScript",
      "category": "Programming",
      "tags": ["JavaScript", "web development", "coding"]
    }
  ],

  index = pages | find_index: 'category', 'Programming'
-%}

{{ pages[index].title }}
```

```plain title="output"
Mastering JavaScript
```

Alternatively we can pass a lambda expression. When the expression is applied to each array item, the index of the first item that evaluates to `true` will be returned.

```liquid2
{# ...continued from above #}
{%- assign index = pages | find_index: page -> (page.category == 'Programming') -%}
{{ pages[index].title }}
```

```plain title="output"
Mastering JavaScript
```

## first

```
<sequence> | first
```

Return the first item of the input sequence. The input could be array-like, a mapping or a string.

```liquid2
{{ ["a", "b", "c"] | first }}
{{ "abc" | first }}
```

```plain title="output"
a
a
```

If the input sequence is undefined, empty or not a sequence, the special value `Nothing` is returned.

## flatten

```
<array> | flatten[: <integer>]
```

Return a copy of the input array with nested arrays flattened to at most the given depth.

```liquid2
{% assign a = [[1, 2, 3, [4, 5, 6]], 7] %}
{{ a | flatten }}
{{ a | flatten: 1 }}
```

```title="Output"
[1,2,3,4,5,6,7]
[1,2,3,[4,5,6],7]
```

If the optional depth argument can not be cast to an integer, it defaults to 1.

## flat_map

```
<array> | flat_map: <string|lambda>
```

Transform and flatten the input array into a new array.

If a string argument is given, array items should be objects and the argument a property name.

```liquid2
{% assign
  items = [
    { "prices": [3, 10, 99] },
    { "prices": [1, 0.5, 42] },
    { "prices": [87, 24, 1] },
  ],

  total = items | flat_map: "prices" | sum
%}

{{ total }}
```

```title="Output"
267.5
```

If the argument is a lambda expression, the expression is applied to each array item before flattening.

```liquid2
{% assign
  items = [
    { "prices": [3, 10, 99] },
    { "prices": [1, 0.5, 42] },
    { "prices": [87, 24, 1] },
  ],

  total = items | flat_map: (i) -> [7, ...i.prices] | sum
%}

{{ total }}
```

```title="Output"
288.5
```

## floor

```
<number> | floor
```

Return the input number rounded down to the nearest whole number.

```liquid2
{{ 1.2 | floor }}
{{ 2.0 | floor }}
{{ 183.357 | floor }}
{{ -5.4 | floor }}
{{ "3.5" | floor }}
```

```plain title="output"
1
2
183
-6
3
```

If the input can't be converted to a number, the special value `Nothing` is returned.

## join

```
<array> | join[: <string>]
```

Return concatenated items from the input array separated by the argument string. If array items are not strings, they will be converted to strings before joining.

```liquid2
{% assign beatles = ["John", "Paul", "George", "Ringo"] -%}
{{ beatles | join: " and " }}
```

```plain title="output"
John and Paul and George and Ringo
```

If separator is not given it defaults to a single space.

```liquid2
{% assign beatles = ["John", "Paul", "George", "Ringo"] -%}
{{ beatles | join }}
```

```plain title="output"
John Paul George Ringo
```

## json

```
<any> | json[: pretty:<bool>]
```

Return the input value as a JSON-formatted string.

```liquid2
{%- assign
  data = {
    "foo": 42,
    "bar": "baz"
  }
-%}

{{ data | json }}
{{ data | json: pretty:true }}
```

```title="Output"
{"foo":42,"bar":"baz"}
{
  "foo": 42,
  "bar": "baz"
}
```

## last

```
<array> | last
```

Return the last item in the array-like input.

```liquid2
{{ "Ground control to Major Tom." | split: " " | last }}
```

```plain title="output"
Tom.
```

If the input is undefined, empty, string or a number, `nil` will be returned.

## lstrip

```
<string> | lstrip
```

Return the input string with all leading whitespace removed. If the input is not a string, it will
be converted to a string before stripping whitespace.

```liquid2
{{ "          So much room for activities          " | lstrip }}!
```

```plain title="output"
So much room for activities          !
```

## map

```
<array> | map: <string | lambda expression>
```

Extract properties from an array of objects into a new array.

For example, if `pages` is an array of objects with a `category` property:

```json title="data"
{
  "pages": [
    { "category": "business" },
    { "category": "celebrities" },
    { "category": "lifestyle" },
    { "category": "sports" },
    { "category": "technology" }
  ]
}
```

```liquid2
{% assign categories = pages | map: "category" -%}

{% for category in categories -%}
- {{ category }}
{%- endfor %}
```

```plain title="output"
- business
- celebrities
- lifestyle
- sports
- technology
```

## max

TODO:

## min

TODO:

## minus

```
<number> | minus: <number>
```

Return the result of subtracting one number from another. If either the input or argument are not a number, Liquid will try to convert them to a number. If that conversion fails, `0` is used instead.

```liquid2
{{ 4 | minus: 2 }}
{{ "16" | minus: 4 }}
{{ 183.357 | minus: 12.2 }}
{{ "hello" | minus: 10 }}
```

```plain title="output"
2
12
171.157
-10
```

## modulo

```
<number> | modulo: <number>
```

Return the remainder from the division of the input by the argument.

```liquid2
{{ 3 | modulo: 2 }}
{{ "24" | modulo: "7" }}
{{ 183.357 | modulo: 12 }}
```

```plain title="output"
1
3
3.357
```

If either the input or argument are not an integer or float, Liquid will try to convert them to an
integer or float. If the input can't be converted, `0` will be used instead. If the argument can't
be converted, an exception is raised.

## newline_to_br

```
<string> | newline_to_br
```

Return the input string with `\n` and `\r\n` replaced with `<br />\n`.

```liquid2
{% capture string_with_newlines %}
Hello
there
{% endcapture %}

{{ string_with_newlines | newline_to_br }}
```

```plain title="output"


<br />
Hello<br />
there<br />

```

## plus

```
<number> | plus: <number>
```

Return the result of adding one number to another. If either the input or argument are not a number, Liquid will try to convert them to a number. If that conversion fails, `0` is used instead.

```liquid2
{{ 4 | plus: 2 }}
{{ "16" | plus: "4" }}
{{ 183.357 | plus: 12 }}
```

```plain title="output"
6
20
195.357
```

## prepend

```
<string> | prepend: <string>
```

Return the argument concatenated with the filter input.

```liquid2
{{ "apples, oranges, and bananas" | prepend: "Some fruit: " }}
```

```plain title="output"
Some fruit: apples, oranges, and bananas
```

If either the input value or argument are not a string, they will be coerced to a string before
concatenation.

```liquid2
{% assign a_number = 7.5 -%}
{{ 42 | prepend: a_number }}
{{ nosuchthing | prepend: 'World!' }}
```

```plain title="output"
7.542
World!
```

## reject

```
<array> | reject: <string>[, <object>]
```

Return a copy of the input array including only those objects that have a property, named with the first argument, **that is not equal to** a value, given as the second argument. If a second argument is not given, only elements with the named property that are falsy will be included.

```json title="data"
{
  "products": [
    { "title": "Vacuum", "type": "house", "available": true },
    { "title": "Spatula", "type": "kitchen", "available": false },
    { "title": "Television", "type": "lounge", "available": true },
    { "title": "Garlic press", "type": "kitchen", "available": true }
  ]
}
```

```liquid2
All products:
{% for product in products -%}
- {{ product.title }}
{% endfor %}

{%- assign kitchen_products = products | reject: "type", "kitchen" -%}

Non kitchen products:
{% for product in kitchen_products -%}
- {{ product.title }}
{% endfor %}

{%- assign unavailable_products = products | reject: "available" -%}

Unavailable products:
{% for product in unavailable_products -%}
- {{ product.title }}
{% endfor %}
```

```plain title="output"
All products:
- Vacuum
- Spatula
- Television
- Garlic press
Non kitchen products:
- Vacuum
- Television
Unavailable products:
- Spatula
```

## remove

```
<string> | remove: <string>
```

Return the input with all occurrences of the argument string removed.

```liquid2
{{ "I strained to see the train through the rain" | remove: "rain" }}
```

```plain title="output"
I sted to see the t through the
```

If either the filter input or argument are not a string, they will be coerced to a string before
substring removal.

## remove_first

```
<string> | remove_first: <string>
```

Return a copy of the input string with the first occurrence of the argument string removed.

```liquid2
{{ "I strained to see the train through the rain" | remove_first: "rain" }}
```

```plain title="output"
I sted to see the train through the rain
```

If either the filter input or argument are not a string, they will be coerced to a string before substring removal.

## remove_last

```
<string> | remove_last: <string>
```

Return a copy of the input string with the last occurrence of the argument string removed.

```liquid2
{{ "I strained to see the train through the rain" | remove_last: "rain" }}
```

```plain title="output"
I strained to see the train through the
```

If either the filter input or argument are not a string, they will be coerced to a string before substring removal.

## replace

```
<string> | replace: <string>[, <string>]
```

Return the input with all occurrences of the first argument replaced with the second argument. If
the second argument is omitted, it will default to an empty string, making `replace` behave like
`remove`.

```liquid2
{{ "Take my protein pills and put my helmet on" | replace: "my", "your" }}
```

```plain title="output"
Take your protein pills and put your helmet on
```

If either the filter input or argument are not a string, they will be coerced to a string before
replacement.

## replace_first

```
<string> | replace_first: <string>[, <string>]
```

Return a copy of the input string with the first occurrence of the first argument replaced with the second argument. If the second argument is omitted, it will default to an empty string, making `replace_first` behave like `remove_first`.

```liquid2
{{ "Take my protein pills and put my helmet on" | replace_first: "my", "your" }}
```

```plain title="output"
Take your protein pills and put my helmet on
```

If either the filter input or argument are not a string, they will be coerced to a string before replacement.

## replace_last

```
<string> | replace_last: <string>, <string>
```

Return a copy of the input string with the last occurrence of the first argument replaced with the second argument.

```liquid2
{{ "Take my protein pills and put my helmet on" | replace_first: "my", "your" }}
```

```plain title="output"
Take my protein pills and put your helmet on
```

If either the filter input or argument are not a string, they will be coerced to a string before replacement.

## reverse

```
<array> | reverse
```

Return a copy of the input array with the items in reverse order. If the filter input is a string, `reverse` will return the string unchanged.

```liquid2
{% assign my_array = "apples, oranges, peaches, plums" | split: ", " -%}

{{ my_array | reverse | join: ", " }}
```

```plain title="output"
plums, peaches, oranges, apples
```

## round

```
<number> | round[: <number>]
```

Return the input number rounded to the given number of decimal places. The number of digits defaults to `0`.

```liquid2
{{ 1.2 | round }}
{{ 2.7 | round }}
{{ 183.357 | round: 2 }}
```

```plain title="output"
1
3
183.36
```

If either the filter input or its optional argument are not an integer or float, they will be converted to an integer or float before rounding.

## rstrip

```
<string> | rstrip
```

Return the input string with all trailing whitespace removed. If the input is not a string, it will be converted to a string before stripping whitespace.

```liquid2
{{ "          So much room for activities          " | rstrip }}!
```

```plain title="output"
          So much room for activities!
```

## safe

```
<string> | safe
```

Return the input string marked as safe to use in an HTML or XML document. If the filter input is not a string, it will be converted to an HTML-safe string.

With auto-escape enabled and the following global variables:

```json title="data"
{
  "username": "Sally",
  "greeting": "</p><script>alert('XSS!');</script>"
}
```

```liquid2 title="template"
<p>{{ greeting }}, {{ username }}</p>
<p>{{ greeting | safe }}, {{ username }}</p>
```

```html title="output"
<p>&lt;/p&gt;&lt;script&gt;alert(&#34;XSS!&#34;);&lt;/script&gt;, Sally</p>
<p></p><script>alert('XSS!');</script>, Sally</p>
```

## size

```
<object> | size
```

Return the size of the input object. Works on strings, arrays and hashes.

```liquid2
{{ "Ground control to Major Tom." | size }}
{{ "apples, oranges, peaches, plums" | split: ", " | size }}
```

```plain title="output"
28
4
```

## slice

```
<sequence> | slice: <int>[, <int>]
```

Return a substring or subsequence of the input string or array. The first argument is the zero-based start index. The second, optional argument is the length of the substring or sequence, which defaults to `1`.

```liquid2
{{ "Liquid" | slice: 0 }}
{{ "Liquid" | slice: 2 }}
{{ "Liquid" | slice: 2, 5 }}
{% assign beatles = "John, Paul, George, Ringo" | split: ", " -%}
{{ beatles | slice: 1, 2 | join: " " }}
```

```plain title="output"
L
q
quid
Paul George
```

If the first argument is negative, the start index is counted from the end of the sequence.

```liquid2
{{ "Liquid" | slice: -3 }}
{{ "Liquid" | slice: -3, 2 }}
{% assign beatles = "John, Paul, George, Ringo" | split: ", " -%}
{{ beatles | slice: -2, 2 | join: " " }}
```

```plain title="output"
u
ui
George Ringo
```

## sort

````
<array> | sort[: <string>]
``

Return a copy of the input array with its elements sorted.

```liquid
{% assign my_array = "zebra, octopus, giraffe, Sally Snake" | split: ", " -%}
{{ my_array | sort | join: ", " }}
````

```plain title="output"
Sally Snake, giraffe, octopus, zebra
```

The optional argument is a sort key. If given, it should be the name of a property and the filter's input should be an array of objects.

```json title="data"
{
  "collection": {
    "products": [
      { "title": "A Shoe", "price": "9.95" },
      { "title": "A Tie", "price": "0.50" },
      { "title": "A Hat", "price": "2.50" }
    ]
  }
}
```

```liquid2 title="template"
{% assign products_by_price = collection.products | sort: "price" -%}
{% for product in products_by_price %}
  <h4>{{ product.title }}</h4>
{% endfor %}
```

```plain title="output"
<h4>A Tie</h4>
<h4>A Hat</h4>
<h4>A Shoe</h4>
```

## sort_natural

```
<array> | sort_natural[: <string>]
```

Return a copy of the input array with its elements sorted case-insensitively. Array items will be compared by their string representations, forced to lowercase.

```liquid2
{% assign my_array = "zebra, octopus, giraffe, Sally Snake" | split: ", " -%}
{{ my_array | sort_natural | join: ", " }}
```

```plain title="output"
giraffe, octopus, Sally Snake, zebra
```

The optional argument is a sort key. If given, it should be the name of a property and the filter's input should be an array of objects. Array elements are compared using the lowercase string representation of that property.

```json title="data"
{
  "collection": {
    "products": [
      { "title": "A Shoe", "company": "Cool Shoes" },
      { "title": "A Tie", "company": "alpha Ties" },
      { "title": "A Hat", "company": "Beta Hats" }
    ]
  }
}
```

```liquid2 title="template"
{% assign products_by_company = collection.products | sort_natural: "company" %}
{% for product in products_by_company %}
  <h4>{{ product.title }}</h4>
{% endfor %}
```

```plain title="output"
<h4>A Tie</h4>
<h4>A Hat</h4>
<h4>A Shoe</h4>
```

## sort_numeric

TODO

## split

```
<string> | split: <string>
```

Return an array of strings that are the input string split on the filter's argument string.

```liquid2
{% assign beatles = "John, Paul, George, Ringo" | split: ", " -%}

{% for member in beatles %}
  {{- member }}
{% endfor %}
```

```plain title="output"
John
Paul
George
Ringo
```

If the argument is undefined or an empty string, the input will be split at every character.

```liquid2
{{ "Hello there" | split: nosuchthing | join: "#" }}
```

```plain title="output"
H#e#l#l#o# #t#h#e#r#e
```

## squish

```
<string> | squish
```

Return the input string with all leading and trailing whitespace removed, and any other runs of whitespace replaced with a single space.

```liquid2
{{ "    Hello, \n\t World! \r\n" | squish }}
```

```plain title="output"
Hello, World!
```

## strip

```
<string> | strip
```

Return the input string with all leading and trailing whitespace removed. If the input is not a string, it will be converted to a string before stripping whitespace.

```liquid2
{{ "          So much room for activities          " | strip }}!
```

```plain title="output"
So much room for activities!
```

## strip_html

```
<string> | strip_html
```

Return the input string with all HTML tags removed.

```liquid2
{{ "Have <em>you</em> read <strong>Ulysses</strong>?" | strip_html }}
```

```plain title="output"
Have you read Ulysses?
```

## strip_newlines

```
<string> | strip_newlines
```

Return the input string with `\n` and `\r\n` removed.

```liquid2
{% capture string_with_newlines %}
Hello
there
{% endcapture -%}

{{ string_with_newlines | strip_newlines }}
```

```plain title="output"
Hellothere
```

## sum

```
<array> | sum[: <string>]
```

Return the sum of all numeric elements in an array.

```liquid2
{% assign array = '1,2,3' | split: ',' -%}
{{ array | sum }}
```

```plain title="output"
6
```

If the optional string argument is given, it is assumed that array items are hash/dict/mapping-like, and the argument should be the name of a property/key. The values at `array[property]` will be summed.

## take

TODO

## times

```
<number> | times: <number>
```

Return the product of the input number and the argument. If either the input or argument are not a number, Liquid will try to convert them to a number. If that conversion fails, `0` is used instead.

```liquid2
{{ 3 | times: 2 }}
{{ "24" | times: "7" }}
{{ 183.357 | times: 12 }}
```

```plain title="output"
6
168
2200.284
```

## truncate

```
<string> | truncate[: <integer>[, <string>]]
```

Return a truncated version of the input string. The first argument, length, defaults to `50`. The second argument defaults to an ellipsis (`...`).

If the length of the input string is less than the given length (first argument), the input string will be truncated to `length` minus the length of the second argument, with the second argument appended.

```liquid2
{{ "Ground control to Major Tom." | truncate: 20 }}
{{ "Ground control to Major Tom." | truncate: 25, ", and so on" }}
{{ "Ground control to Major Tom." | truncate: 20, "" }}
```

```plain title="output"
Ground control to...
Ground control, and so on
Ground control to Ma
```

## truncatewords

```
<string> | truncatewords[: <integer>[, <string>]]
```

Return the input string truncated to the specified number of words, with the second argument appended. The number of words (first argument) defaults to `15`. The second argument defaults to an ellipsis (`...`).

If the input string already has fewer than the given number of words, it is returned unchanged.

```liquid2
{{ "Ground control to Major Tom." | truncatewords: 3 }}
{{ "Ground control to Major Tom." | truncatewords: 3, "--" }}
{{ "Ground control to Major Tom." | truncatewords: 3, "" }}
```

```plain title="output"
Ground control to...
Ground control to--
Ground control to
```

## uniq

```
<array> | uniq[: <string>]
```

Return a copy of the input array with duplicate elements removed.

```liquid2
{% assign my_array = "ants, bugs, bees, bugs, ants" | split: ", " -%}
{{ my_array | uniq | join: ", " }}
```

```plain title="output"
ants, bugs, bees
```

If an argument is given, it should be the name of a property and the filter's input should be an array of objects.

```json title="data"
{
  "collection": {
    "products": [
      { "title": "A Shoe", "company": "Cool Shoes" },
      { "title": "A Tie", "company": "alpha Ties" },
      { "title": "Another Tie", "company": "alpha Ties" },
      { "title": "A Hat", "company": "Beta Hats" }
    ]
  }
}
```

```liquid2 title="template"
{% assign one_product_from_each_company = collections.products | uniq: "company" -%}
{% for product in one_product_from_each_company -%}
  - product.title
{% endfor %}
```

```plain title="output"
- A Shoe
- A Tie
- A Hat
```

## upcase

```
<string> | upcase
```

Return the input string with all characters in uppercase.

```liquid2
{{ 'Hello, World!' | upcase }}
```

```plain title="output"
HELLO, WORLD!
```

## url_decode

```
<string> | url_decode
```

Return the input string with `%xx` escapes replaced with their single-character equivalents. Also replaces `'+'` with `' '`.

```liquid2
{{ "My+email+address+is+bob%40example.com%21" | url_decode }}
```

```plain title="output"
My email address is bob@example.com!
```

## url_encode

```
<string> | url_encode
```

Return the input string with URL reserved characters %-escaped. Also replaces `' '` with `'+'`.

```liquid2
{{ My email address is bob@example.com! | url_encode }}
```

```plain title="output"
My+email+address+is+bob%40example.com%21
```

## where

```
<array> | where: <string>[, <object>]
```

Return a copy of the input array including only those objects that have a property, named with the first argument, equal to a value, given as the second argument. If a second argument is not given, only elements with the named property that are truthy will be included.

```json title="data"
{
  "products": [
    { "title": "Vacuum", "type": "house", "available": true },
    { "title": "Spatula", "type": "kitchen", "available": false },
    { "title": "Television", "type": "lounge", "available": true },
    { "title": "Garlic press", "type": "kitchen", "available": true }
  ]
}
```

```liquid2
All products:
{% for product in products -%}
- {{ product.title }}
{% endfor %}

{%- assign kitchen_products = products | where: "type", "kitchen" -%}

Kitchen products:
{% for product in kitchen_products -%}
- {{ product.title }}
{% endfor %}

{%- assign available_products = products | where: "available" -%}

Available products:
{% for product in available_products -%}
- {{ product.title }}
{% endfor %}
```

```plain title="output"
All products:
- Vacuum
- Spatula
- Television
- Garlic press

Kitchen products:
- Spatula
- Garlic press

Available product:
- Vacuum
- Television
- Garlic press
```

## zip

TODO:
