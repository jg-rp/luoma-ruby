# frozen_string_literal: true

module Luoma
  module Filters
    # Return the size of _left_, or zero if _left_ has no size.
    def self.size(context, left)
      return left.length(context.render_context) if left.is_a?(Drop)
      return left.size if left.respond_to?(:size)

      0
    end
  end
end
