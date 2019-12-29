import decode.{Decoder, decode_dynamic}
import gleam/atom as atom_mod
import gleam/dynamic.{Dynamic}
import gleam/result
import gleam/string

// TYPES

pub type JsonError {
  InvalidJson // this means that the jsone erlang function failed in an expected way (which we assume to be because the JSON was invalid)
  DecodingFailure(String) // this means that Erlang to Gleam decoding failed—-TODO, come up with a better name?
}

pub type JsonDecoder(a) {
  JsonDecoder(
    fn(Dynamic) -> Result(a, JsonError)
  )
}


// JSON TERMS

pub fn int() -> JsonDecoder(Int) {
  JsonDecoder(
    fn(json_dyn) {
      dynamic.int(json_dyn)
      |> result.map_error(_, DecodingFailure)
    }
  )
}


// DECODING

external fn jsone_try_decode(String) -> Dynamic
  = "jsone" "try_decode"

type JsoneTryDecodeResult {
  JsoneDecodeSuccess(Dynamic)
  JsoneDecodeFailure // TODO: Add more granularity to this?
}

// 1. Get the first element in the tuple, which is an atom (technically could
//    fail but probably won't)
// 2. Check whether the atom is ok or error (this determines whether the JSON
//    is invalid or not)
// 3. If the JSON is valid, return the Dynamic that it has become
fn jsone_try_decode_decoder() -> Decoder(JsoneTryDecodeResult) {
  let ok_decoder =
    decode.element(1, decode.dynamic())
    |> decode.map(JsoneDecodeSuccess, _)
  let error_decoder =
    decode.succeed(JsoneDecodeFailure)
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

pub fn decode_json(
  json: String,
  with json_decoder: JsonDecoder(a)
) -> Result(a, JsonError)
{
  let JsonDecoder(json_decode_fun) = json_decoder

  json
  |> jsone_try_decode
  |> decode_dynamic(_, jsone_try_decode_decoder())
  |> result.map_error(_, DecodingFailure)
  |> result.then(_, fn(jsone_try_decode_result) {
    case jsone_try_decode_result {
      JsoneDecodeSuccess(dyn) -> json_decode_fun(dyn)
      JsoneDecodeFailure -> Error(InvalidJson)
    }
  })
}

pub external fn dangerous_decode_json(String) -> Dynamic
  = "jsone" "decode"

pub external fn dangerous_encode_json(Dynamic) -> String
  = "jsone" "encode"
