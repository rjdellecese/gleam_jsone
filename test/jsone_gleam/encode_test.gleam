import decode.{decode_dynamic}
import gleam/expect
import gleam/result
import jsone_gleam/encode.{
  encode_json,
  string,
  int,
  float,
  array,
  null,
  bool,
  object
}

pub fn string_test() {
  "string"
  |> string
  |> encode_json
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("\"string\""))
}

pub fn int_test() {
  1
  |> int
  |> encode_json
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("1"))
}

pub fn float_test() {
  // TODO: Test other float formats
  1.23
  |> float
  |> encode_json
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_,  Ok("1.22999999999999998224e+00"))
}

pub fn list_test() {
  [1, 2, 3]
  |> array(_, int)
  |> encode_json
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("[1,2,3]"))
}

pub fn null_test() {
  null()
  |> encode_json
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("null"))
}

pub fn bool_test() {
  True
  |> bool
  |> encode_json
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("true"))
}

pub fn object_test() {
  object([
    tuple("int_field", int(1)),
    tuple("string_field", string("string"))
  ])
  |> encode_json
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("{\"int_field\":1,\"string_field\":\"string\"}"))
}
