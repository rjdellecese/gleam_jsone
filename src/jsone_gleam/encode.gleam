import decode.{Decoder, decode_dynamic}
import gleam/map
import gleam/pair
import gleam/atom as atom_mod
import gleam/dynamic.{Dynamic}
import gleam/list as list_mod

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
  let ok_decoder = decode.element(1, decode.dynamic())
  let error_decoder = decode.fail("Invalid JSON value")

  decode.ok_error_tuple(ok_decoder, error_decoder)
}

pub fn encode_json(json_value: JsonValue) -> Result(Dynamic, String) {
  json_value
  |> prepare_for_encoding
  |> jsone_try_encode
  |> decode_dynamic(_, jsone_try_decoder())
}
