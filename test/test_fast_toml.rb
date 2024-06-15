# frozen_string_literal: true

require 'test_helper'
require 'benchmark/ips'
require 'toml'
require 'toml-rb'
require 'perfect_toml'
require 'tomlrb'
require 'date'

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

  DATE_TOML_INPUT = <<~TOML
    date1 = 1979-05-27T07:32:00Z
    date2 = 1979-05-27T00:32:00-07:00
    date3 = 1979-05-27T00:32:00.999999-07:00
    date4 = 1979-05-27T07:32:00
    date5 = 1979-05-27T00:32:00.999999
    date6 = 1979-05-27
    date7 = 07:32:00
    date8 = 00:32:00.999999
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

  def test_date_parsing
    parsed = FastToml.parse(DATE_TOML_INPUT)

    expected_dates = {
      'date1' => DateTime.parse('1979-05-27T07:32:00Z'),
      'date2' => DateTime.parse('1979-05-27T00:32:00-07:00'),
      'date3' => DateTime.parse('1979-05-27T00:32:00.999999-07:00'),
      'date4' => DateTime.parse('1979-05-27T07:32:00'),
      'date5' => DateTime.parse('1979-05-27T00:32:00.999999'),
      'date6' => Date.parse('1979-05-27'),
      'date7' => '07:32:00',
      'date8' => '00:32:00.999999'
    }

    expected_dates.each do |key, expected_date|
      assert_equal expected_date, parsed[key], "Failed for #{key}"
    end
  end
end
