import jsone_gleam.{decode, encode}
import gleam/dynamic
import gleam/expect

pub fn decode_test() {
  "1"
  |> decode
  |> dynamic.int(_)
  |> expect.equal(_, Ok(1))
}

pub fn encode_test() {
  1
  |> dynamic.from
  |> encode
  |> expect.equal(_, "1")
}
