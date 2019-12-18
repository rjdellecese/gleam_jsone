import jsone_gleam
import gleam/dynamic
import gleam/expect

pub fn parse_json_test() {
  jsone_gleam.parse_json("1")
  |> expect.equal(_, dynamic.from(1))
}
