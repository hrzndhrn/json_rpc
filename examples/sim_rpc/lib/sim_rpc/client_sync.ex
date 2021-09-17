defmodule SimRPC.ClientSync do
  use JsonRPC, transport: SimRPC.Transport, async: false

  rpc add(a, b)

  rpc msg(text), notification: true

  rpc message(text), notification: true, delegate: "msg"

  rpc params(map), params: :by_name

  rpc divide(a, b)

  rpc missing()
end
