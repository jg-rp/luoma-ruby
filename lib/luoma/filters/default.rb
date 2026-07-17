# frozen_string_literal: true

module Luoma
  # Liquid filters and helper methods.
  module Filters
    # Return _left_, or _default_ if _obj_ is `nil`, `false` or empty.
    # If _allow_false_ is `true`, _left_ is returned if _left_ is `false`.
    def self.default(context, left, default = "", allow_false: false)
      return default if left.is_a?(FalsyStrictUndefinedDrop)

      left_ = left.is_a?(Drop) ? left.to_primitive(:boolean, context.render_context) : left
      return left_ if allow_false && left_ == false

      !context.truthy?(left_) || Luoma::Predicates.empty?(context.render_context, left_) ? default : left_
    end
  end
end
