# gleam_jsone

[![Hex.pm](https://img.shields.io/hexpm/v/gleam_jsone)](https://hex.pm/packages/gleam_jsone) [![HexDocs.pm](https://img.shields.io/badge/hex-docs-ff69b4)](https://hexdocs.pm/gleam_jsone/)

Gleam bindings to the fast, simple JSON decoding/encoding Erlang library,
[`jsone`](https://github.com/sile/jsone).

This library will always aim to track the latest `jsone` release. You can find
the latest `jsone` documentation [here](https://hexdocs.pm/jsone/).

Although fully functional, **please note** that this library currently has very
unhelpful error messages. If you are using it and would like better, please open
an issue (or, of course, a PR)!

Once we have nice error messages, we'll be ready for v1.0.0!

## Installation

Add `gleam_jsone` to the deps section of your `rebar.config` file.

```erlang
{deps, [
    {gleam_jsone, "0.5.0"}
]}.
```

## Examples

This library allows you to decode JSON `String`s into Erlang `Dynamic` data. In
order to turn that into Gleam data, you'll either need to use the functions for
`Dynamic` data in the Gleam standard library, or a library like
[`gleam_decode`](https://github.com/rjdellecese/gleam_decode). The examples
below use the standard library functions, but you can check out the test suite
for examples that use `gleam_decode`.

```rust
import gleam/dynamic
import gleam/jsone
import gleam/result

pub fn decode_json_int() -> Result(Int, String) {
  "1"
  |> jsone.decode
  |> result.then(fn(json_dynamic) {
    dynamic.int(json_dynamic)
  }) //=> Ok(1)
};

pub fn decode_json_object_field() -> Result(Bool, String) {
  "{ \"boolean\": true }"
  |> jsone.decode
  |> result.then(fn(json_dynamic) {
    dynamic.field(json_dynamic, "boolean")
  })
  |> result.then(fn(boolean_field_dynamic) {
    dynamic.bool(boolean_field_dynamic)
  }) //=> Ok(true)
};

pub type JsonObject {
  JsonObject(
    boolean: Bool,
    int: Int
  )
};

pub fn decode_json_object() -> Result(JsonObject, String) {
  let dynamic_object_result =
    "
    {
      \"boolean\": true,
      \"int\": 1
    }
    "
    |> jsone.decode

  let boolean_value_result =
    dynamic_object_result
    |> result.then(fn(dynamic_object) {
      dynamic_object
      |> dynamic.field("boolean")
      |> result.then(fn(dynamic_boolean) {
        dynamic.bool(dynamic_boolean)
      })
    })

  let int_value_result =
    dynamic_object_result
    |> result.then(fn(dynamic_object) {
      dynamic_object
      |> dynamic.field("int")
      |> result.then(fn(dynamic_int) {
        dynamic.int(dynamic_int)
      })
    })

  case boolean_value_result, int_value_result {
    Ok(boolean_value), Ok(int_value) -> Ok(JsonObject(boolean_value, int_value))
    _, _ -> Error("Couldn't decode JSON into JsonObject.")
  } //=> Ok(JsonObject(true, 1))
};

pub fn decode_bad_json() -> Result(Int, String) {
  "<1x.1"
  |> jsone.decode
  |> result.then(fn(json_dynamic) {
    dynamic.int(json_dynamic)
  }) //=> Error("Invalid JSON value")
}
```
