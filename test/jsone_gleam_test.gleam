import jsone_gleam.{decode_json, dangerous_decode_json, dangerous_encode_json}
import gleam/dynamic
import gleam/expect

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

pub fn decode_json_int_test() {
  "1"
  |> decode_json(_, jsone_gleam.int())
  |> expect.equal(_, Ok(1))
}

pub fn decode_json_invalid_test() {
  "<1x.1"
  |> decode_json(_, jsone_gleam.int())
  |> expect.equal(_, Error(jsone_gleam.InvalidJson))
}

pub fn dangerous_decode_json_test() {
  "1"
  |> dangerous_decode_json
  |> dynamic.int(_)
  |> expect.equal(_, Ok(1))
}

pub fn dangerous_encode_json_test() {
  1
  |> dynamic.from
  |> dangerous_encode_json
  |> expect.equal(_, "1")
}
