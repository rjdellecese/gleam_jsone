import decode.{decode_dynamic}
import gleam/atom.{Atom}
import gleam/expect
import gleam/result
import jsone_gleam/decode.{
  decode_json,
  decode_json_with_options,
  Options,
  DuplicateMapKeys
} as jsone_decode

fn json_basics() -> String {
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
  }
  "
}

type JsonBasicsObject {
  JsonBasicsObject(
    a: String,
    c: String,
    e: String
  )
}

type JsonBasicsColor {
  JsonBasicsColorHex(String)
}

type JsonBasics {
  JsonBasics(
    array: List(Int),
    boolean: Bool,
    color: JsonBasicsColor,
    null: Atom,
    number: Int,
    object: JsonBasicsObject,
    string: String
  )
}

pub fn decode_json_test() {
  "1"
  |> decode_json
  |> result.then(_, decode_dynamic(_, decode.int()))
  |> expect.equal(_, Ok(1))

  "<1x.1"
  |> decode_json
  |> expect.equal(_, Error("Invalid JSON"))

  let json_basics_object_decoder =
    decode.map3(
      JsonBasicsObject,
      decode.field("a", decode.string()),
      decode.field("c", decode.string()),
      decode.field("e", decode.string())
    )

  let json_basics_decoder =
    decode.map7(
      JsonBasics,
      decode.field("array", decode.list(decode.int())),
      decode.field("boolean", decode.bool()),
      decode.field("color", decode.map(JsonBasicsColorHex, decode.string())),
      decode.field("null", decode.atom()),
      decode.field("number", decode.int()),
      decode.field("object",json_basics_object_decoder),
      decode.field("string", decode.string())
    )

  json_basics()
  |> decode_json
  |> result.then(_, decode_dynamic(_, json_basics_decoder))
  |> expect.equal(_, Ok(
    JsonBasics(
      array: [1, 2, 3],
      boolean: True,
      color: JsonBasicsColorHex("#82b92c"),
      null: atom.create_from_string("null"),
      number: 123,
      object: JsonBasicsObject(
        a: "b",
        c: "d",
        e: "f"
      ),
      string: "Hello World"
    )
  ))
}

pub fn duplicate_map_keys_test() {
  let json_with_duplicate_keys =
    "
    {
      \"duplicate\": \"first\",
      \"duplicate\": \"last\"
    }
    "

  let duplicate_decoder = decode.field("duplicate", decode.string())
  let duplicate_keys_first_option =
    Options(
      duplicate_map_keys: jsone_decode.First,
      allow_ctrl_chars: False
    )

  json_with_duplicate_keys
  |> decode_json_with_options(_, duplicate_keys_first_option)
  |> result.then(_, decode_dynamic(_, duplicate_decoder))
  |> expect.equal(_, Ok("first"))

  let duplicate_keys_last_option =
    Options(
      duplicate_map_keys: jsone_decode.Last,
      allow_ctrl_chars: False
    )

  json_with_duplicate_keys
  |> decode_json_with_options(_, duplicate_keys_last_option)
  |> result.then(_, decode_dynamic(_, duplicate_decoder))
  |> expect.equal(_, Ok("last"))
}

external fn string_with_unescaped_newline() -> String =
  "test_helpers" "string_with_unescaped_newline"

external fn string_with_escaped_newline() -> String =
  "test_helpers" "string_with_escaped_newline"

pub fn allow_ctrl_chars_test() {
  let allow_ctrl_chars_false_option =
    Options(
      duplicate_map_keys: jsone_decode.First,
      allow_ctrl_chars: False
    )

  string_with_unescaped_newline()
  |> decode_json_with_options(_, allow_ctrl_chars_false_option)
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.is_error

  string_with_escaped_newline()
  |> decode_json_with_options(_, allow_ctrl_chars_false_option)
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.is_ok

  let allow_ctrl_chars_true_option =
    Options(
      duplicate_map_keys: jsone_decode.First,
      allow_ctrl_chars: True
    )

  string_with_unescaped_newline()
  |> decode_json_with_options(_, allow_ctrl_chars_true_option)
  |> result.then(_, decode_dynamic(_, decode.string()))
  |> expect.is_ok
}
