# frozen_string_literal: true

require "cgi/escape"

module Luoma
  module Filters
    # Escape characters for safe use in JavaScript string literals.
    def self.escape_js(context, left)
      Luoma.escape_js(context.to_string(left))
    end
  end
end
