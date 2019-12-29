import decode.{Decoder, decode_dynamic}
import gleam/atom as atom_mod
import gleam/dynamic.{Dynamic}
import gleam/string

// DECODING

external fn jsone_try_decode(String) -> Dynamic
  = "jsone" "try_decode"

fn jsone_try_decode_decoder() -> Decoder(Dynamic) {
  let ok_decoder =
    decode.element(1, decode.dynamic())
  let error_decoder =
    decode.fail("Invalid JSON")
  let failure_decoder =
    fn(atom_as_string) {
      "Unexpected atom '"
      |> string.append(_, atom_as_string)
      |> string.append(_, "' in first position of tuple")
      |> decode.fail
    }

  let success_or_failure_fun =
    fn(result_atom) {
      case atom_mod.to_string(result_atom) {
        "ok" ->
          ok_decoder
        "error" ->
          error_decoder
        atom_as_string ->
          failure_decoder(atom_as_string)
      }
    }

  decode.element(0, decode.atom())
  |> decode.then(_, success_or_failure_fun)
}

pub fn decode_json(json: String) -> Result(Dynamic, String) {
  json
  |> jsone_try_decode
  |> decode_dynamic(_, jsone_try_decode_decoder())
}


// ENCODING
