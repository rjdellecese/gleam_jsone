import jsone_gleam.{dangerous_decode, dangerous_encode}
import gleam/dynamic
import gleam/expect

pub fn dangerous_decode_test() {
  "1"
  |> dangerous_decode
  |> dynamic.int(_)
  |> expect.equal(_, Ok(1))
}

pub fn dangerous_encode_test() {
  1
  |> dynamic.from
  |> dangerous_encode
  |> expect.equal(_, "1")
}
