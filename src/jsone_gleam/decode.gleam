import decode.{Decoder, decode_dynamic}
import gleam/atom as atom_mod
import gleam/dynamic.{Dynamic}
import gleam/string
import gleam/map
import gleam/pair
import gleam/list as list_mod

// TODO: Add options.

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
