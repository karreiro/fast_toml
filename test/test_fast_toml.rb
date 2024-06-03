# frozen_string_literal: true

require 'test_helper'
require 'benchmark/ips'
require 'toml'
require 'toml-rb'
require 'perfect_toml'
require 'tomlrb'

class TestFastToml < Minitest::Test
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

  def test_that_it_has_a_version_number
    refute_nil ::FastToml::VERSION
  end

  def test_basic_parsing
    results = []

    results << FastToml.parse(TOML_INPUT)
    results << TOML::Parser.new(TOML_INPUT).parsed
    results << TomlRB.parse(TOML_INPUT)
    results << PerfectTOML.parse(TOML_INPUT)
    results << Tomlrb.parse(TOML_INPUT)

    assert_equal(1, results.uniq.size)
  end

  def test_parse_errors
    err = assert_raises { FastToml.parse('name = [') }

    assert_equal("invalid array\nexpected `]`", err.message)
  end
end
