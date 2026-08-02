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

```plain title="Output"
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

```plain title="Output"

0
99
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

```plain title="Output"
Hello, World!
```

If either the input value or argument are not a string, they will be coerced to a string before concatenation.

```liquid2
{% assign a_number = 7.5 -%}
{{ 42 | append: a_number }}
{{ nosuchthing | append: 'World!' }}
```

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"
Hello, world!
```

If the input value is not a string, it will be converted to a string.

```liquid2
{{ 42 | capitalize }}
```

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"

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

```plain title="Output"
Mar 14, 16
```

The special `'now'` or `'today'` input values can be used to get the current timestamp. `'today'` is an alias for `'now'`. Both include time information.

```liquid2
{{ "now" | date: "%Y-%m-%d %H:%M" }}
```

```plain title="Output"
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

```plain title="Output"
1.99
2.99
[1,2,3]
```

If the optional `allow_false` argument is `true`, an input of `false` will be passed through.

```liquid2
{{ false | default: 42, allow_false: true }}
```

```plain title="Output"
false
```

If no argument is given, the default value will be an empty string.

```liquid2
{{ false | default }}
```

```plain title="Output"

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

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"
hello, world!
```

If the input is not a string, it will be converted to a string before forcing characters to lowercase.

```liquid2
{{ 5 | downcase }}
```

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"
Mastering JavaScript
```

Alternatively we can pass a lambda expression. When the expression is applied to each array item, the first item that evaluates to `true` will be returned.

```liquid2
{# ...continued from above #}

{{ (pages | find: page -> (page.category == 'Programming')).title }}
```

```plain title="Output"
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

```plain title="Output"
Mastering JavaScript
```

Alternatively we can pass a lambda expression. When the expression is applied to each array item, the index of the first item that evaluates to `true` will be returned.

```liquid2
{# ...continued from above #}
{%- assign index = pages | find_index: page -> (page.category == 'Programming') -%}
{{ pages[index].title }}
```

```plain title="Output"
Mastering JavaScript
```

## first

```
<sequence> | first
```

Return the first item in the input sequence. The input could be array-like, a mapping or a string.

```liquid2
{{ ["a", "b", "c"] | first }}
{{ "abc" | first }}
```

```plain title="Output"
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

```plain title="Output"
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

Return items from the input array concatenated separated by the argument string. If array items are not strings, they will be converted to strings before joining.

```liquid2
{% assign beatles = ["John", "Paul", "George", "Ringo"] -%}
{{ beatles | join: " and " }}
```

```plain title="Output"
John and Paul and George and Ringo
```

If separator is not given it defaults to a single space.

```liquid2
{% assign beatles = ["John", "Paul", "George", "Ringo"] -%}
{{ beatles | join }}
```

```plain title="Output"
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
<sequence> | last
```

Return the last item in the input sequence. The input could be array-like, a mapping or a string.

```liquid2
{{ ["a", "b", "c"] | last }}
{{ "abc" | last }}
```

```plain title="Output"
c
c
```

If the input sequence is undefined, empty or not a sequence, the special value `Nothing` is returned.

## lstrip

```
<string> | lstrip
```

Return a copy of the input string with all leading whitespace removed. If the input is not a string, it will be converted to a string before stripping whitespace.

```liquid2
{{ "          So much room for activities          " | lstrip }}!
```

```plain title="Output"
So much room for activities          !
```

## map

```
<array> | map: <string|lambda>
```

Transform items from the input array into a new array.

If a string argument is given, array items should be objects and the argument a property name.

```liquid2
{% assign
  pages = [
    { "category": "business" },
    { "category": "celebrities" },
    { "category": "lifestyle" },
    { "category": "sports" },
    { "category": "technology" }
  ],

  categories = pages | map: "category"
-%}

{% for category in categories ~%}
- {{ category }}
{% endfor -%}
```

```plain title="Output"
- business
- celebrities
- lifestyle
- sports
- technology
```

If a lambda expression is given, apply the expression to every item in the input array.

```liquid2
{# ...continued from above #}
{{ pages | map: (p) -> (p.category | upcase) | join: '\n' }}
```

```title="Output"
BUSINESS
CELEBRITIES
LIFESTYLE
SPORTS
TECHNOLOGY
```

## max

```
<array> | max[: <string|lambda>]
```

Return the item from the input array with the maximum numeric value.

```liquid2
{{ [1, 10, 9] | max }}
{{ ['1', '10', '-9'] | max }}
{{ ['1', 'foo', '10', '-99'] | max }}
{{ [{'a': 100}, {'a': -100}] | max: 'a' }}
{{ [{'a': 100}, {'a': -100}] | max: o -> o.a }}
```

```title="Output"
10
10
10
{"a":100}
{"a":100}
```

If the input can't be coerced to an array, the input array is empty or contains no numeric values, `nil` is returned.

## min

```
<array> | min[: <string|lambda>]
```

Return the item from the input array with the minimum numeric value.

```liquid2
{{ [1, 10, 9] | min }}
{{ ['1', '10', '-9'] | min }}
{{ ['1', 'foo', '10', '-99'] | min }}
{{ [{'a': 100}, {'a': -100}] | min: 'a' }}
{{ [{'a': 100}, {'a': -100}] | min: o -> o.a }}
```

```title="Output"
1
-9
-99
{"a":-100}
{"a":-100}
```

If the input can't be coerced to an array, is empty or contains no numeric values, `nil` is returned.

## minus

```
<number> | minus: <number>
```

Return the result of subtracting the input number from the argument number. If either input or argument can not be coerced to numbers, the special value `Nothing` is returned.

```liquid2
{{ 4 | minus: 2 }}
{{ "16" | minus: 4 }}
{{ 183.357 | minus: 12.2 }}
{{ "hello" | minus: 10 }}
```

```plain title="Output"
2
12
171.157

```

## modulo

```
<number> | modulo: <number>
```

Return the remainder from dividing the input number by the argument number. If either input or argument are not numeric of the argument is zero, the special value `Nothing` is returned.

```liquid2
{{ 3 | modulo: 2 }}
{{ "24" | modulo: "7" }}
{{ 183.357 | modulo: 12 }}
```

```plain title="Output"
1
3
3.357
```

## newline_to_br

```
<string> | newline_to_br
```

Return the input string with `\n` and `\r\n` replaced with `<br />\n`.

```liquid2
{{ "Hello\nthere" | newline_to_br }}
```

```plain title="Output"
Hello<br />
there
```

## plus

```
<number> | plus: <number>
```

Return the result of adding the input number to the argument number. If either the input or argument are not numeric, the special value `Nothing` is returned.

```liquid2
{{ 4 | plus: 2 }}
{{ "16" | plus: "4" }}
{{ 183.357 | plus: 12 }}
```

```plain title="Output"
6
20
195.357
```

## prepend

```
<string> | prepend: <string>
```

Return the argument string concatenated with the input string.

```liquid2
{{ "apples, oranges, and bananas" | prepend: "Some fruit: " }}
```

```plain title="Output"
Some fruit: apples, oranges, and bananas
```

## reject

```
<array> | reject: <string>[, <any>]
<array> | reject: <lambda>
```

Return a new array containing items from the input array for which the argument expression evaluates to `null` or `false`.

```liquid2
{%- assign
  products = [
    { "title": "Vacuum", "type": "house", "available": true },
    { "title": "Spatula", "type": "kitchen", "available": false },
    { "title": "Television", "type": "lounge", "available": true },
    { "title": "Garlic press", "type": "kitchen", "available": true }
  ]
-%}

{{ products | reject: "type", "kitchen" | json: pretty=true }}
{{ products | reject: p -> (p.type == "kitchen" and not p.available) | json: pretty=true }}
```

```plain title="Output"
[
  {
    "title": "Vacuum",
    "type": "house",
    "available": true
  },
  {
    "title": "Television",
    "type": "lounge",
    "available": true
  }
]
[
  {
    "title": "Vacuum",
    "type": "house",
    "available": true
  },
  {
    "title": "Television",
    "type": "lounge",
    "available": true
  },
  {
    "title": "Garlic press",
    "type": "kitchen",
    "available": true
  }
]
```

## remove

```
<string> | remove: <string>
```

Return a copy of the input string with all occurrences of the argument string removed.

```liquid2
{{ "I strained to see the train through the rain" | remove: "rain" }}
```

```plain title="Output"
I sted to see the t through the
```

## remove_first

```
<string> | remove_first: <string>
```

Return a copy of the input string with the first occurrence of the argument string removed.

```liquid2
{{ "I strained to see the train through the rain" | remove_first: "rain" }}
```

```plain title="Output"
I sted to see the train through the rain
```

## remove_last

```
<string> | remove_last: <string>
```

Return a copy of the input string with the last occurrence of the argument string removed.

```liquid2
{{ "I strained to see the train through the rain" | remove_last: "rain" }}
```

```plain title="Output"
I strained to see the train through the
```

## replace

```
<string> | replace: <string>[, <string>]
```

Return a copy of the input string with all occurrences of the first argument replaced with the second argument. If
the second argument is omitted, it will default to an empty string, making `replace` behave like
`remove`.

```liquid2
{{ "Take my protein pills and put my helmet on" | replace: "my", "your" }}
```

```plain title="Output"
Take your protein pills and put your helmet on
```

## replace_first

```
<string> | replace_first: <string>[, <string>]
```

Return a copy of the input string with the first occurrence of the first argument replaced with the second argument. If the second argument is omitted, it will default to an empty string, making `replace_first` behave like `remove_first`.

```liquid2
{{ "Take my protein pills and put my helmet on" | replace_first: "my", "your" }}
```

```plain title="Output"
Take your protein pills and put my helmet on
```

## replace_last

```
<string> | replace_last: <string>, <string>
```

Return a copy of the input string with the last occurrence of the first argument replaced with the second argument.

```liquid2
{{ "Take my protein pills and put my helmet on" | replace_first: "my", "your" }}
```

```plain title="Output"
Take my protein pills and put your helmet on
```

## reverse

```
<sequence> | reverse
```

Return items from the input sequence in reverse order.

```liquid2
{%- assign
  array = ["apples", "oranges", "peaches", "plums"],
  string = "Hello",
  object = {"a": 1, "b": 2},
 -%}

{{ array | reverse }}
{{ string | reverse }}
{{ object | reverse }}
```

```plain title="Output"
["plums","peaches","oranges","apples"]
["o","l","l","e","H"]
[["b",2],["a",1]]
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

```plain title="Output"
1
3
183.36
```

## rstrip

```
<string> | rstrip
```

Return the input string with all trailing whitespace removed. If the input is not a string, it will be converted to a string before stripping whitespace.

```liquid2
{{ "          So much room for activities          " | rstrip }}!
```

```plain title="Output"
          So much room for activities!
```

## size

```
<sequence> | size
```

Return a count of items in the input sequence.

```liquid2
{{ "Ground control to Major Tom." | size }}
{{ ["apples", "oranges", "peaches", "plums"] | size }}
```

```plain title="Output"
28
4
```

## slice

```
<sequence> | slice[: <integer>[, <integer>[, <integer>]]]
<sequence> | slice: start=<integer>, stop=<integer>, step=<integer>,
```

Return a subsequence of items in the input sequence. A starting index, stop index and step size can be given as positional or keyword arguments. Start defaults to zero, stop defaults to the length of the input, and step default to `1`.

The resulting array is includes the start index and excludes the stop index.

```liquid2
{{ "Luoma" | slice: 0 }}
{{ "Luoma" | slice: 2 }}
{{ "Luoma" | slice: 1, 3 }}
{{ ["John", "Paul", "George", "Ringo"] | slice: 1, 2  }}
{{ [1, 2, 3, 4, 5, 6] | slice: step=2 }}
```

```plain title="Output"
["L","u","o","m","a"]
["o","m","a"]
["u","o"]
["Paul"]
[1,3,5]
```

Negative indexes work too.

```liquid2
{{ [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] | slice: start=-1, stop=-5, step=-1 }}
```

```title="Output"
[9,8,7,6]
```

## sort

```
<array> | sort[: <string|lambda>]
```

Return items from the input array sorted in ascending order.

```liquid
{{ ["zebra", "octopus", "giraffe", "Sally Snake"] | sort }}
```

```title="Output"
["Sally Snake","giraffe","octopus","zebra"]
```

If a string argument is given, array items should be objects and the argument should be the name of a property to sort by.

```liquid2 title="template"
{%- assign
  collection = {
    "products": [
      { "title": "A Shoe", "price": "9.95" },
      { "title": "A Tie", "price": "0.50" },
      { "title": "A Hat", "price": "2.50" }
    ]
  }
-%}

{% for product in collection.products | sort: "price" ~%}
  <h4>{{ product.title }}</h4>
{% endfor -%}
```

```title="Output"
  <h4>A Tie</h4>
  <h4>A Hat</h4>
  <h4>A Shoe</h4>
```

## sort_numeric

```
<array> | sort_numeric[: <string|lambda>]
```

Return items from the input array sorted by runs of digits found in the string representation of each item.

```liquid2
{%- assign
  a = ["107", "042", "0001", "02", "17"],
  b = [
    { "y": "-1", "x": "10" },
    { "x": "3" },
    { "x": "2" },
    { "x": "1" },
  ]
-%}

{{ a | sort_numeric }}
{{ b | sort_numeric: o => o.x | json: pretty=true }}
```

```title="Output"
["0001","02","17","042","107"]
[
  {
    "x": "1"
  },
  {
    "x": "2"
  },
  {
    "x": "3"
  },
  {
    "y": "-1",
    "x": "10"
  }
]
```

## split

```
<string> | split: <string>
```

Return an array of substrings by splitting the input string at each occurrence of the argument string.

```liquid2
{% assign beatles = "John, Paul, George, Ringo" | split: ", " -%}

{% for member in beatles %}
  {{- member }}
{% endfor %}
```

```title="Output"
John
Paul
George
Ringo
```

If the argument is undefined or an empty string, the input will be split at every character.

```liquid2
{{ "Hello there" | split: nosuchthing | join: "#" }}
```

```plain title="Output"
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

```plain title="Output"
Hello, World!
```

## strip

```
<string> | strip
```

Return the input string with all leading and trailing whitespace removed.

```liquid2
{{ "          So much room for activities          " | strip }}!
```

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"
Hellothere
```

## sum

```
<array> | sum[: <string|lambda>]
```

Return the sum of all numeric elements in the input array.

```liquid2
{{ [1, 2, 3] | sum }}
```

```plain title="Output"
6
```

If a string argument is given, array items should be objects and the argument should be the name of a property. The values at `array[property]` will be summed.

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

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"
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

```plain title="Output"
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
