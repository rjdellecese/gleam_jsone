import decode.{Decoder, decode_dynamic} as dynamic_decode
import gleam/atom as atom_mod
import gleam/dynamic.{Dynamic}
import gleam/string
import gleam/map
import gleam/pair
import gleam/list as list_mod


//
// DECODING
//

// OPTIONS

pub type DuplicateMapKeys {
  First
  Last
}

pub type Options {
  Options(
    allow_ctrl_chars: Bool,
    reject_invalid_utf8: Bool,
    duplicate_map_keys: DuplicateMapKeys
  )
}

pub fn default_options() -> Options {
  Options(
    allow_ctrl_chars: False,
    reject_invalid_utf8: False,
    duplicate_map_keys: First
  )
}

// Transforms the jsone options from Gleam into their proper Erlang format.
fn transform_options(options: Options) -> Dynamic {
  let Options(
    duplicate_map_keys: duplicate_map_keys,
    reject_invalid_utf8: reject_invalid_utf8,
    allow_ctrl_chars: allow_ctrl_chars
  ) = options

  let duplicate_map_keys_dynamic =
    tuple(
      atom_mod.create_from_string("duplicate_map_keys"),
      case duplicate_map_keys {
        First -> atom_mod.create_from_string("first")
        Last -> atom_mod.create_from_string("last")
      }
    )
    |> dynamic.from

  let allow_ctrl_chars_dynamic =
    tuple(
      atom_mod.create_from_string("allow_ctrl_chars"),
      allow_ctrl_chars
    )
    |> dynamic.from

  let reject_invalid_utf8_dynamic =
    atom_mod.create_from_string("reject_invalid_utf8")
    |> dynamic.from

  let maybe_prepend_reject_invalid_utf8_dynamic =
    fn(options: List(Dynamic)) {
      case reject_invalid_utf8 {
        True -> [reject_invalid_utf8_dynamic | options]
        False -> options
      }
    }

  [duplicate_map_keys_dynamic, allow_ctrl_chars_dynamic]
  |> maybe_prepend_reject_invalid_utf8_dynamic
  |> dynamic.from
}


// ERRORS

// pub type JsonDecodeError {
//   
// }


// PERFORM DECODING

external fn jsone_try_decode(String) -> Dynamic
  = "jsone" "try_decode"

external fn jsone_try_decode_with_options(String, Dynamic) -> Dynamic
  = "jsone" "try_decode"

fn jsone_try_decode_decoder() -> Decoder(Dynamic) {
  let ok_decoder = dynamic_decode.element(1, dynamic_decode.dynamic())
  let error_decoder = dynamic_decode.fail("Invalid JSON")

  dynamic_decode.ok_error_tuple(ok_decoder, error_decoder)
}

pub fn decode(json: String) -> Result(Dynamic, String) {
  json
  |> jsone_try_decode
  |> decode_dynamic(_, jsone_try_decode_decoder())
}

pub fn decode_with_options(
  json: String,
  options: Options
) -> Result(Dynamic, String)
{
  json
  |> jsone_try_decode_with_options(_, transform_options(options))
  |> decode_dynamic(_, jsone_try_decode_decoder())
}


//
// ENCODING
//

// OPTIONS
//
// TODO: Add options.

pub type JsonNumber {
  JsonInt(Int)
  JsonFloat(Float)
}

pub type JsonValue {
  JsonString(String)
  JsonNumber(JsonNumber)
  JsonArray(List(JsonValue))
  JsonBool(Bool)
  JsonNull
  JsonObject(List(tuple(String, JsonValue)))
}

pub fn string(string: String) -> JsonValue {
  JsonString(string)
}

pub fn int(int: Int) -> JsonValue {
  JsonNumber(JsonInt(int))
}

pub fn float(float: Float) -> JsonValue {
  JsonNumber(JsonFloat(float))
}

pub fn array(list: List(a), encoder: fn(a) -> JsonValue) -> JsonValue {
  list
  |> list_mod.map(_, encoder)
  |> JsonArray
}

pub fn bool(bool: Bool) -> JsonValue {
  JsonBool(bool)
}

pub fn null() -> JsonValue {
  JsonNull
}

pub fn object(object: List(tuple(String, JsonValue))) -> JsonValue {
  JsonObject(object)
}

fn prepare_for_encoding(json_value: JsonValue) -> Dynamic {
  case json_value {
    JsonString(string) -> dynamic.from(string)
    JsonNumber(json_number) ->
      case json_number {
        JsonInt(int) -> dynamic.from(int)
        JsonFloat(float) -> dynamic.from(float)
      }
    JsonArray(list) ->
      list
      |> list_mod.map(_, prepare_for_encoding)
      |> dynamic.from
    JsonNull ->
      "null"
      |> atom_mod.create_from_string
      |> dynamic.from
    JsonBool(bool) -> dynamic.from(bool)
    JsonObject(object) ->
      object
      |> list_mod.map(_, pair.map_second(_, prepare_for_encoding))
      |> map.from_list
      |> dynamic.from
  }
}

external fn jsone_try_encode(Dynamic) -> Dynamic =
  "jsone" "try_encode"

fn jsone_try_decoder() -> Decoder(Dynamic)  {
  let ok_decoder = dynamic_decode.element(1, dynamic_decode.dynamic())
  let error_decoder = dynamic_decode.fail("Invalid JSON value")

  dynamic_decode.ok_error_tuple(ok_decoder, error_decoder)
}

pub fn encode(json_value: JsonValue) -> Result(Dynamic, String) {
  json_value
  |> prepare_for_encoding
  |> jsone_try_encode
  |> decode_dynamic(_, jsone_try_decoder())
}
