import gleam/dynamic.{Dynamic}

pub external fn dangerous_decode(String) -> Dynamic
  = "jsone" "decode"

pub external fn dangerous_encode(Dynamic) -> String
  = "jsone" "encode"
