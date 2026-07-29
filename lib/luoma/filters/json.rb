# frozen_string_literal: true

module Luoma
  module Filters
    # Return _left_ serialized in JSON format.
    def self.json(context, left, pretty: false)
      if pretty
        JSON.pretty_generate(left)
      else
        JSON.generate(left)
      end
    end
  end
end
