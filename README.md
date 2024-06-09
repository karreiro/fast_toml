# FastToml

[![Ruby](https://github.com/karreiro/fast_toml/actions/workflows/ci.yml/badge.svg)](https://github.com/karreiro/fast_toml/actions/workflows/ci.yml)

FastToml is a high-performance TOML parser for Ruby. It significantly outperforms other TOML parsers available in the Ruby ecosystem by wrapping the Rust `toml` parser in a native extension. FastToml is currently more than twice as fast as the next best parser and nearly 200 times faster than some others.


## Installation

To install FastToml, add it to your application's Gemfile by executing:

```
$ bundle add fast_toml
```

If bundler is not being used to manage dependencies, install the gem by executing:

```
$ gem install fast_toml
```

## Usage

To use FastToml, require the gem and parse your TOML input as shown in the example below:

```ruby
require 'fast_toml'

parsed_data = FastToml.parse <<~TOML
  [package]
  name = "fast_toml"
  version = "0.1.0"
  edition = "2021"
  license = "MIT"

  [dependencies]
  magnus = "0.6.4"
  toml = "0.8.13"
TOML
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Releasing a New Version

To release a new version, follow these steps:
- Bump the version number in `lib/fast_toml/version.rb`
- Bump the version number in `ext/fast_toml/Cargo.toml`
- Run `bundle install && bundle rake`
- Push your commit
- Push a new tag called `vX.Y.Z`
- Create a release using the GitHub UI

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/fast_toml. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/fast_toml/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the FastToml project's codebases, issue trackers, chat rooms, and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/fast_toml/blob/main/CODE_OF_CONDUCT.md).
