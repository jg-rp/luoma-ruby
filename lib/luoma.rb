# frozen_string_literal: true

require "bigdecimal/util"
require_relative "luoma/chain_hash"
require_relative "luoma/context"
require_relative "luoma/drop"
require_relative "luoma/environment"
require_relative "luoma/errors"
require_relative "luoma/expression"
require_relative "luoma/filter"
require_relative "luoma/fnv"
require_relative "luoma/lexer"
require_relative "luoma/lexer_unified"
require_relative "luoma/loader"
require_relative "luoma/loaders/mixins"
require_relative "luoma/loaders/file_system_loader"
require_relative "luoma/markup"
require_relative "luoma/parser"
require_relative "luoma/parser_unified"
require_relative "luoma/template"
require_relative "luoma/token"
require_relative "luoma/version"
require_relative "luoma/drops/block"
require_relative "luoma/drops/forloop"
require_relative "luoma/drops/range"
require_relative "luoma/drops/undefined"
require_relative "luoma/filters/array"
require_relative "luoma/filters/date"
require_relative "luoma/filters/default"
require_relative "luoma/filters/math"
require_relative "luoma/filters/size"
require_relative "luoma/filters/slice"
require_relative "luoma/filters/sort"
require_relative "luoma/filters/string"
require_relative "luoma/tags/assign"
require_relative "luoma/tags/block"
require_relative "luoma/tags/break"
require_relative "luoma/tags/capture"
require_relative "luoma/tags/case"
require_relative "luoma/tags/comment"
require_relative "luoma/tags/continue"
require_relative "luoma/tags/cycle"
require_relative "luoma/tags/decrement"
require_relative "luoma/tags/else"
require_relative "luoma/tags/for"
require_relative "luoma/tags/if"
require_relative "luoma/tags/include"
require_relative "luoma/tags/increment"
require_relative "luoma/tags/output"
require_relative "luoma/tags/raw"
require_relative "luoma/tags/render"
require_relative "luoma/tags/unless"
require_relative "luoma/tags/with"

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
    DEFAULT_ENVIRONMENT.render(source, data)
  end
end
