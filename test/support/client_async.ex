defmodule Test.ClientAsync do
  @moduledoc false

  use JsonRPC, transport: Test.TransportAsync, id: JsonRPC.UUID

  rpc add(a, b)

  rpc sub(a, b)

  rpc subtraction(a, b), delegate: "sub"

  rpc divide(a, b)

  rpc keys(map), params: :by_name

  rpc keys_to_list(map), params: :by_name, delegate: "keys"

  rpc hello(map), notification: true, params: :by_name

  rpc say_hello(map), notification: true, params: :by_name, delegate: "hello"

  rpc say(msg), notification: true

  rpc msg(msg), notification: true, delegate: "say"

  rpc missing

  rpc kaput
end
