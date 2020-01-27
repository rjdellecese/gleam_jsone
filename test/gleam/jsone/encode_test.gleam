import decode.{decode_dynamic}
import gleam/expect
import gleam/result
import gleam/jsone

pub fn string_test() {
  "string"
  |> jsone.string
  |> jsone.encode
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("\"string\""))
}

pub fn int_test() {
  1
  |> jsone.int
  |> jsone.encode
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("1"))
}

pub fn float_test() {
  // TODO: Test other float formats
  1.23
  |> jsone.float
  |> jsone.encode
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_,  Ok("1.22999999999999998224e+00"))
}

pub fn list_test() {
  [1, 2, 3]
  |> jsone.array(_, jsone.int)
  |> jsone.encode
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("[1,2,3]"))
}

pub fn null_test() {
  jsone.null()
  |> jsone.encode
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("null"))
}

pub fn bool_test() {
  True
  |> jsone.bool
  |> jsone.encode
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("true"))
}

pub fn object_test() {
  jsone.object([
    tuple("int_field", jsone.int(1)),
    tuple("string_field", jsone.string("string"))
  ])
  |> jsone.encode
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("{\"int_field\":1,\"string_field\":\"string\"}"))
}
