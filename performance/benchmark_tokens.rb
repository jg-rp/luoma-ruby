# frozen_string_literal: true

require "benchmark/ips"
require "json"
require "pathname"
require "luoma"

# A benchmark fixture
class Fixture
  attr_reader :templates, :data, :name

  # @param path [Pathname]
  def initialize(path)
    @root = path
    @name = @root.basename.to_s
    # rubocop:disable Style/StringConcatenation
    @data = JSON.parse((@root + "data.json").read)
    @templates = (@root + "templates").glob("*liquid").to_h { |p| [p.basename.to_s, p.read] }
    # rubocop:enable Style/StringConcatenation
  end

  def env
    Luoma::Environment.new
  end
end

fixture = Fixture.new(Pathname.new("test/golden_liquid/benchmark_fixtures/002/"))
env = fixture.env
source = fixture.templates["index.liquid"]

Benchmark.ips do |x|
  # Configure the number of seconds used during
  # the warmup phase (default 2) and calculation phase (default 5)
  x.config(warmup: 2, time: 5)

  x.report("tokenize (#{fixture.name}):") do
    Luoma::LegacyLexer.tokenize(env, source)
  end
end
