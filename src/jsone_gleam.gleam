import decode.{Decoder, decode_dynamic}
import gleam/atom as atom_mod
import gleam/dynamic.{Dynamic}
import gleam/string
import gleam/map
import gleam/pair
import gleam/list as list_mod

// TODO: Add some decoding/encoding options.

// DECODING
//
// TODO: Write a set of decoders specifically for JSON?

external fn jsone_try_decode(String) -> Dynamic
  = "jsone" "try_decode"

fn jsone_try_decode_decoder() -> Decoder(Dynamic) {
  let ok_decoder = decode.element(1, decode.dynamic())
  let error_decoder = decode.fail("Invalid JSON")

  decode.ok_error_tuple(ok_decoder, error_decoder)
}

pub fn decode_json(json: String) -> Result(Dynamic, String) {
  json
  |> jsone_try_decode
  |> decode_dynamic(_, jsone_try_decode_decoder())
}


// ENCODING

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

pub fn encode_string(string: String) -> JsonValue {
  JsonString(string)
}

pub fn encode_int(int: Int) -> JsonValue {
  JsonNumber(JsonInt(int))
}

pub fn encode_float(float: Float) -> JsonValue {
  JsonNumber(JsonFloat(float))
}

pub fn encode_array(list: List(a), encoder: fn(a) -> JsonValue) -> JsonValue {
  list
  |> list_mod.map(_, encoder)
  |> JsonArray
}

pub fn encode_bool(bool: Bool) -> JsonValue {
  JsonBool(bool)
}

pub fn encode_null() -> JsonValue {
  JsonNull
}

pub fn encode_object(object: List(tuple(String, JsonValue))) -> JsonValue {
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

fn jsone_try_encode_decoder() -> Decoder(Dynamic)  {
  let ok_decoder = decode.element(1, decode.dynamic())
  let error_decoder = decode.fail("Invalid JSON value")

  decode.ok_error_tuple(ok_decoder, error_decoder)
}

pub fn encode_json(json_value: JsonValue) -> Result(Dynamic, String) {
  json_value
  |> prepare_for_encoding
  |> jsone_try_encode
  |> decode_dynamic(_, jsone_try_encode_decoder())
}
