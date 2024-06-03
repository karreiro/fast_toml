use magnus::exception::runtime_error;
use magnus::function;
use magnus::prelude::*;
use magnus::value::{InnerValue, Lazy};
use magnus::RModule;
use magnus::{IntoValue, RArray, RHash, Ruby};

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), magnus::Error> {
    let module = ruby.define_module("FastToml")?;
    module.define_singleton_method("parse", function!(parse, 1))?;
    Ok(())
}

fn parse(str: String) -> Result<magnus::Value, magnus::Error> {
    let toml_value = toml::from_str(&str);

    match toml_value {
        Ok(toml_value) => {
            let ruby_value = to_ruby_value(toml_value);
            Ok(ruby_value)
        }
        Err(err) => {
            let ruby_err = to_ruby_err(err.message());
            Err(ruby_err)
        }
    }
}

fn to_ruby_err(err_msg: &str) -> magnus::Error {
    let ruby_api = Ruby::get();

    if let Ok(ruby_api) = ruby_api {
        let module = fast_toml_module(&ruby_api);

        let err_class = module
            .define_error("Error", ruby_api.exception_standard_error())
            .expect("Failed to define or get FastToml::Error");

        return magnus::Error::new(err_class, err_msg.to_string());
    }

    magnus::Error::new(runtime_error(), "FastToml runtime err")
}

fn fast_toml_module(ruby_api: &Ruby) -> RModule {
    Lazy::new(|ruby| {
        ruby.define_module("FastToml")
            .expect("Failed to define or get FastToml")
    })
    .get_inner_with(ruby_api)
}

fn to_ruby_value(value: toml::Value) -> magnus::Value {
    match value {
        toml::Value::String(string) => string.into_value(),
        toml::Value::Integer(integer) => integer.into_value(),
        toml::Value::Float(float) => float.into_value(),
        toml::Value::Boolean(boolean) => boolean.into_value(),
        toml::Value::Datetime(date) => date.to_string().into_value(),
        toml::Value::Array(rust_array) => {
            let ruby_array = RArray::new();

            for value in rust_array {
                let value = to_ruby_value(value);
                ruby_array.push(value).unwrap();
            }

            ruby_array.into_value()
        }
        toml::Value::Table(rust_map) => {
            let ruby_hash = RHash::new();

            for (key, value) in rust_map {
                let value = to_ruby_value(value);
                ruby_hash.aset(key, value).unwrap();
            }

            ruby_hash.into_value()
        }
    }
}
