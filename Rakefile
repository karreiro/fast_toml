# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path(__dir__)

require 'bundler/gem_tasks'
require 'minitest/test_task'
require 'rubocop/rake_task'
require 'rb_sys/extensiontask'
require 'lib/fast_toml'

Minitest::TestTask.create

RuboCop::RakeTask.new

GEMSPEC = Gem::Specification.load('fast_toml.gemspec')

RbSys::ExtensionTask.new('fast_toml', GEMSPEC) do |ext|
  ext.lib_dir = 'lib/fast_toml'
end

task build: :compile

task default: %i[compile test rubocop]
