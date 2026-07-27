# Data types

Luoma has weak typing. Anywhere a particular type is expected - like filter and tag arguments - Luoma will automatically convert a value to the required type. This implicit conversion can never fail. That is, the expression language is _total_.

The following basic data types are supported. All other types - either built-in or custom - inherit from `Luoma::Drop` and implement the _drop interface_.

| Luoma type | Ruby type  | Example Luoma literal  |
| ---------- | ---------- | ---------------------- |
| Boolean    | bool       | `true` or `false`      |
| Null       | nil        | `null` or `nil`        |
| Integer    | Integer    | `123`, `0`, `-7`       |
| Float      | Float      | `1.23`, `0.1`          |
| String     | String     | `"Hello"` or `'Hello'` |
| Array      | Array      | `[1, 2, 3]`            |
| Object     | Hash       | `{"a": 1, "b": 42}`    |
| Nothing    | `:nothing` |                        |

## Extension types

A drop is a developer-defined type that plays nicely with Luoma tags, filters, predicates and operators. Drops are often used to implement lazy data retrieval or context sensitive logic.

The base drop, `Luoma::Drop`, is falsy, is an empty iterable/enumerable, is equal to nothing (including itself) and renders as an empty string.

TODO: document the complete Drop API.

## Built-in drops

### `BlockDrop`

A `Luoma::BlockDrop` encapsulates a block of Luoma markup. When an instance of `BlockDrop` is rendered, its internal markup is rendered to the output stream using variables from the current context, in the scope where it is "called".

Similarly, if a `BlockDrop` is coerced to a string - passed to a filter or tag that expects a string value - its internal markup is rendered into a new string using variables from the current scope.

Instances of `BlockDrop` are produced by the built-in `{% define %}` tag. When rendered, `{% define some_name %}...{% enddefine %}` binds a `BlockDrop` to the given name without writing to the output stream. This means blocks can be passed around and rendered multiple times in different contexts without loading a separate template.

By default, Luoma has special rules for rendering **arrays** of `BlockDrop`. Given an array of `BlockDrop` instances and no other types, Luoma will render each block to the output stream separated by a single newline character. If an array contains `BlockDrop` instances mixed with strings, those blocks and strings are rendered in order without a separating newline. Otherwise the array is considered data and is output in JSON.

### `ExpressionDrop`

A `Luoma::ExpressionDrop` encapsulates a single Luoma expression for later evaluation. When rendered or coerced to a string, `ExpressionDrop` produces a textual representation of its expression.

Internally, Luoma's filter application operator (`|`) recognizes instances of `ExpressionDrop` as user-defined filters. And some built-in filters accept instances of `ExpressionDrop` as arguments.

Lambda literals (`(a, b) -> expression`) evaluate to an instance of `ExpressionDrop`. `ExpressionDrop` captures nothing about the scope in which it is defined.

### `RangeDrop`

TODO:

### `UndefinedDrop`

TODO:

## Custom drops

TODO:
