# frozen_string_literal: true

require_relative 'lib/fast_toml/version'

Gem::Specification.new do |spec|
  spec.name                                = 'fast_toml'
  spec.version                             = FastToml::VERSION
  spec.authors                             = ['Guilherme Carreiro']
  spec.email                               = ['karreiro@gmail.com']
  spec.summary                             = 'A fast TOML parser.'
  spec.description                         = 'A fast TOML parser.'
  spec.homepage                            = 'https://github.com/karreiro/fast_toml'
  spec.license                             = 'MIT'
  spec.required_ruby_version               = '>= 3.1.0'
  spec.required_rubygems_version           = '>= 3.3.11'

  spec.metadata['allowed_push_host']       = 'https://rubygems.org'
  spec.metadata['changelog_uri']           = 'https://github.com/karreiro/fast_toml/blob/main/CHANGELOG.md'
  spec.metadata['homepage_uri']            = spec.homepage
  spec.metadata['source_code_uri']         = spec.homepage

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.extensions = ['ext/fast_toml/extconf.rb']
  spec.add_dependency 'rb_sys', '0.9.85'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
