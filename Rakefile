# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'minitest/test_task'

Minitest::TestTask.create

require 'rubocop/rake_task'

RuboCop::RakeTask.new

require 'rb_sys/extensiontask'

task build: :compile

GEMSPEC = Gem::Specification.load('fast_toml.gemspec')

RbSys::ExtensionTask.new('fast_toml', GEMSPEC) do |ext|
  ext.lib_dir = 'lib/fast_toml'
end

task default: %i[compile test rubocop]
