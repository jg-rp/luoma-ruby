module Luoma
  class Template
    attr_reader :env

    #: (Environment) -> void
    def initialize(env)
      @env = env
    end
  end
end
