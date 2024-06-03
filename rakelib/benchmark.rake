# frozen_string_literal: true

require 'benchmark'
require 'benchmark/ips'
require 'toml'
require 'toml-rb'
require 'perfect_toml'
require 'tomlrb'

TOML_INPUT = <<~TOML
  [package]
  name = "fast_toml"
  version = "0.1.0"
  edition = "2021"
  authors = ["Guilherme Carreiro <karreiro@gmail.com>"]
  license = "MIT"
  publish = false

  [lib]
  crate-type = ["cdylib"]

  [dependencies]
  magnus = "0.6.4"
  toml = "0.8.13"
TOML

namespace :benchmark do
  desc 'Benchmark different TOML parsers (ips)'
  task :ips do
    Benchmark.ips do |x|
      x.report('fast_toml')    { FastToml.parse(TOML_INPUT) }
      x.report('toml')         { TOML::Parser.new(TOML_INPUT).parsed }
      x.report('toml-rb')      { TomlRB.parse(TOML_INPUT) }
      x.report('perfect_toml') { PerfectTOML.parse(TOML_INPUT) }
      x.report('tomlrb')       { Tomlrb.parse(TOML_INPUT) }

      x.compare!
    end
  end

  desc 'Benchmark different TOML parsers (ms)'
  task :ms do
    n = 5_000

    Benchmark.bm(20) do |x|
      x.report('fast_toml:')    { n.times { FastToml.parse(TOML_INPUT) } }
      x.report('toml:')         { n.times { TOML::Parser.new(TOML_INPUT).parsed } }
      x.report('toml-rb:')      { n.times { TomlRB.parse(TOML_INPUT) } }
      x.report('perfect_toml:') { n.times { PerfectTOML.parse(TOML_INPUT) } }
      x.report('tomlrb:')       { n.times { Tomlrb.parse(TOML_INPUT) } }
    end
  end
end
