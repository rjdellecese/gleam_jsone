import jsone_gleam
import gleam/expect

pub fn hello_world_test() {
  jsone_gleam.hello_world()
  |> expect.equal(_, "Hello, from jsone_gleam!")
}
