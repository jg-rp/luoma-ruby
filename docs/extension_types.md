# Extension types

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

Lambda literals (`(a, b) -> expression`) evaluate to an instance of `ExpressionDrop`, without capturing anything about the scope in which it is defined. Internally, Luoma's filter application operator (`|`) recognizes instances of `ExpressionDrop` as user-defined filters, and some built-in filters accept instances of `ExpressionDrop` as arguments.

### `RangeDrop`

Range literals (`(1..5)`) evaluate to instances of `Luoma::RangeDrop`. When iterated, `RangeDrop` yields integers from its range of integer values.

When rendered or coerced to a string, `RangeDrop` produces a JSON-like array of integers.

### `UndefinedDrop`

Undefined variables resolve to an instance of of `Luoma::UndefinedDrop`, or one of its subclasses. Undefined variable behavior is configured by passing a `Luoma::UndefinedDrop` singleton to `Luoma::Environment.new`.

See [Undefined variables](./undefined_variables.md) for a breakdown of the built-in `Undefined` types.

## Custom drops

TODO:
