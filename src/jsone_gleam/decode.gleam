import decode.{Decoder, decode_dynamic}
import gleam/atom as atom_mod
import gleam/dynamic.{Dynamic}
import gleam/string
import gleam/map
import gleam/pair
import gleam/list as list_mod


// OPTIONS

pub type DuplicateMapKeys {
  First
  Last
}

pub type Options {
  Options(
    allow_ctrl_chars: Bool,
    // reject_invalid_utf8: Bool,
    duplicate_map_keys: DuplicateMapKeys
  )
}

pub fn default_options() -> Options {
  Options(
    allow_ctrl_chars: False,
    // reject_invalid_utf8: True,
    duplicate_map_keys: First
  )
}

// Transforms the jsone options from Gleam into their proper Erlang format.
fn transform_options(options: Options) -> Dynamic {
  let Options(
    duplicate_map_keys: duplicate_map_keys,
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


  [duplicate_map_keys_dynamic, allow_ctrl_chars_dynamic]
  |> dynamic.from
}


// ERRORS

// pub type JsonDecodeError {
//   
// }


// DECODING

external fn jsone_try_decode(String) -> Dynamic
  = "jsone" "try_decode"

external fn jsone_try_decode_with_options(String, Dynamic) -> Dynamic
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

pub fn decode_json_with_options(
  json: String,
  options: Options
) -> Result(Dynamic, String)
{
  json
  |> jsone_try_decode_with_options(_, transform_options(options))
  |> decode_dynamic(_, jsone_try_decode_decoder())
}
