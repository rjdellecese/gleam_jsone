import decode.{decode_dynamic}
import gleam/expect
import gleam/result
import jsone_gleam.{decode_json}

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
  |> decode_json
  |> result.then(_, decode_dynamic(_, decode.int()))
  |> expect.equal(_, Ok(1))
}

pub fn decode_json_invalid_test() {
  "<1x.1"
  |> decode_json
  |> expect.equal(_, Error("Invalid JSON"))
}
