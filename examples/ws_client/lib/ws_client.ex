defmodule WsClient do
  use JsonRPC, transport: WsClient.Transport

  rpc add(a, b)

  rpc divide(a, b)

  rpc message(text), notification: true, delegate: "say"

  rpc params(map), params: :by_name

  def hello, do: message("hello")
end
