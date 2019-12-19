import gleam/dynamic.{Dynamic}

pub external fn decode(String) -> Dynamic
  = "jsone" "decode"

pub external fn encode(Dynamic) -> String
  = "jsone" "encode"
