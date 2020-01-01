import decode.{decode_dynamic}
import gleam/atom.{Atom}
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
