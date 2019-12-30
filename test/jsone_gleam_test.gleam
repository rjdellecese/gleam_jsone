import decode.{decode_dynamic}
import gleam/expect
import gleam/result
import jsone_gleam.{
  decode_json,
  encode_json,
  encode_string,
  encode_int,
  encode_float,
  encode_array,
  encode_null,
  encode_bool,
  encode_object
}

pub fn json_basics() -> String {
  "
  {
  \"array\": [
    1,
    2,
    3
  ],
  \"boolean\": true,
  \"color\": \"#82b92c\",
  \"null\": null,
  \"number\": 123,
  \"object\": {
    \"a\": \"b\",
    \"c\": \"d\",
    \"e\": \"f\"
  },
  \"string\": \"Hello World\"
  "
}

pub fn decode_json_test() {
  "1"
  |> decode_json
  |> result.then(_, decode_dynamic(_, decode.int()))
  |> expect.equal(_, Ok(1))

  "<1x.1"
  |> decode_json
  |> expect.equal(_, Error("Invalid JSON"))
}

pub fn encode_string_test() {
  "string"
  |> encode_string
  |> encode_json
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("\"string\""))
}

pub fn encode_int_test() {
  1
  |> encode_int
  |> encode_json
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("1"))
}

pub fn encode_float_test() {
  // TODO: Test other float formats
  1.23
  |> encode_float
  |> encode_json
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_,  Ok("1.22999999999999998224e+00"))
}

pub fn encode_list_test() {
  [1, 2, 3]
  |> encode_array(_, encode_int)
  |> encode_json
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("[1,2,3]"))
}

pub fn encode_null_test() {
  encode_null()
  |> encode_json
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("null"))
}

pub fn encode_bool_test() {
  True
  |> encode_bool
  |> encode_json
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("true"))
}

pub fn encode_object_test() {
  encode_object([
    tuple("int_field", encode_int(1)),
    tuple("string_field", encode_string("string"))
  ])
  |> encode_json
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.equal(_, Ok("{\"int_field\":1,\"string_field\":\"string\"}"))
}
