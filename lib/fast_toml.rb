# frozen_string_literal: true

require_relative 'fast_toml/version'

begin
  RUBY_VERSION =~ /(\d+\.\d+)/
  require_relative "fast_toml/#{Regexp.last_match(1)}/fast_toml"
rescue LoadError
  require_relative 'fast_toml/fast_toml'
end

module FastToml
  class Error < StandardError; end
  # Your code goes here...
end
