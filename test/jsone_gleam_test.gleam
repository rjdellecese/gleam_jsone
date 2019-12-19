import jsone_gleam
import gleam/dynamic
import gleam/expect

pub fn parse_json_test() {
  jsone_gleam.parse_json("1")
  |> dynamic.int(_)
  |> expect.equal(_, Ok(1))
}
