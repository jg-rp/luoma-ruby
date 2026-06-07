# frozen_string_literal: true

module Luoma
  class Environment
    attr_reader :filters, :strict_filters

    def initialize
      @filters = {} #: Hash[String, [untyped, Integer?]]
      @strict_filters = true
    end
  end
end
