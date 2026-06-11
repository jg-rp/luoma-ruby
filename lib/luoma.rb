# frozen_string_literal: true

require_relative "luoma/chain_hash"
require_relative "luoma/context"
require_relative "luoma/drop"
require_relative "luoma/environment"
require_relative "luoma/errors"
require_relative "luoma/expression"
require_relative "luoma/lexer"
require_relative "luoma/lexer_legacy"
require_relative "luoma/loader"
require_relative "luoma/loaders/mixins"
require_relative "luoma/loaders/file_system_loader"
require_relative "luoma/markup"
require_relative "luoma/parser"
require_relative "luoma/parser_legacy"
require_relative "luoma/template"
require_relative "luoma/token"
require_relative "luoma/version"
require_relative "luoma/drops/blank"
require_relative "luoma/drops/empty"
require_relative "luoma/drops/range"
require_relative "luoma/drops/undefined"
require_relative "luoma/tags/assign"
require_relative "luoma/tags/output"

module Luoma
  DEFAULT_ENVIRONMENT = Environment.new

  # Parse _source_ text as a template using the default template environment.
  #: (String, ?globals: Hash[String, untyped]?) -> Template
  def self.parse(source, globals: nil)
    DEFAULT_ENVIRONMENT.parse(source, globals: globals)
  end

  # Parse and render template _source_ with _data_ as template variables and
  # the default template environment.
  #: (String, ?Hash[String, untyped]?) -> String
  def self.render(source, data = nil)
    DEFAULT_ENVIRONMENT.render(source, data: data)
  end
end
