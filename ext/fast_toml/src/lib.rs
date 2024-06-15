use magnus::exception::runtime_error;
use magnus::function;
use magnus::prelude::*;
use magnus::value::{InnerValue, Lazy};
use magnus::RModule;
use magnus::{IntoValue, RArray, RHash, Ruby};
use chrono::{DateTime, NaiveDate, NaiveDateTime, NaiveTime};

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

fn date_to_ruby_value(date: toml::value::Datetime) -> magnus::Value {
    let ruby_api = Ruby::get().unwrap();
    let date_string = date.to_string();

    // List with different dates and times format, from https://toml.io/en/
    let formats = [
        "%Y-%m-%dT%H:%M:%SZ",      // UTC time
        "%Y-%m-%dT%H:%M:%S%:z",    // ISO 8601 with timezone
        "%Y-%m-%dT%H:%M:%S%.f%:z", // ISO 8601 with microseconds and timezone
        "%Y-%m-%dT%H:%M:%S",       // ISO 8601 without timezone
        "%Y-%m-%dT%H:%M:%S%.f",    // ISO 8601 with microseconds
        "%Y-%m-%d",                // Date only
        "%H:%M:%S",                // Time only
        "%H:%M:%S%.f",             // Time with microseconds
    ];

    for format in &formats {
        if let Ok(parsed_date) = DateTime::parse_from_rfc3339(&date_string) {
            let date_time_string = parsed_date.to_rfc3339();
            let date_time_class = ruby_api.eval::<magnus::Value>("DateTime").unwrap();
            return date_time_class.funcall("parse", (date_time_string,)).unwrap();
        } else if let Ok(parsed_date) = NaiveDateTime::parse_from_str(&date_string, format) {
            let date_time_string = parsed_date.format("%Y-%m-%dT%H:%M:%S%.f").to_string();
            let date_time_class = ruby_api.eval::<magnus::Value>("DateTime").unwrap();
            return date_time_class.funcall("parse", (date_time_string,)).unwrap();
        } else if let Ok(parsed_date) = NaiveDate::parse_from_str(&date_string, format) {
            let date_class = ruby_api.eval::<magnus::Value>("Date").unwrap();
            return date_class.funcall("parse", (parsed_date.to_string(),)).unwrap();
        } else if let Ok(parsed_time) = NaiveTime::parse_from_str(&date_string, format) {
            return parsed_time.format("%H:%M:%S%.f").to_string().into_value();
        }
    }

    // Fallback to String, if non of the formats match
    date_string.into_value()
}

fn to_ruby_value(value: toml::Value) -> magnus::Value {
    match value {
        toml::Value::String(string) => string.into_value(),
        toml::Value::Integer(integer) => integer.into_value(),
        toml::Value::Float(float) => float.into_value(),
        toml::Value::Boolean(boolean) => boolean.into_value(),
        toml::Value::Datetime(date) => date_to_ruby_value(date),
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

