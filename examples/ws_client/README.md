# WsClient

This example shows a `JsonRPC` WebSocket client.

The client calls procedures on the [/examples/phx_server](/examples/phx_server).

## Using the example

Starting the server in [/examples/phx_server](/examples/phx_server).

Starting the client:
```shell
iex -S mix
```

Call the RPCs:
```elixir
iex(1)> WsClient.add(1, 2)

16:06:01.841 [info]  send: {"id":-576460752303423483,"jsonrpc":"2.0","method":"add","params":[1,2]}

16:06:01.848 [info]  receive: {"id":-576460752303423483,"jsonrpc":"2.0","result":3}

{:ok, 3}

iex(2)> WsClient.divide(10, 2)

16:06:11.062 [info]  send: {"id":-576460752303423419,"jsonrpc":"2.0","method":"divide","params":[10,2]}

16:06:11.063 [info]  receive: {"id":-576460752303423419,"jsonrpc":"2.0","result":5}

{:ok, 5}

iex(3)> WsClient.divide(10, 0)

16:06:17.896 [info]  send: {"id":-576460752303423355,"jsonrpc":"2.0","method":"divide","params":[10,0]}

16:06:17.899 [info]  receive: {"error":{"code":-32001,"message":"division by zero"},"id":-576460752303423355,"jsonrpc":"2.0"}
{:error, %{code: -32001, message: "division by zero"}}
iex(4)> WsClient.divide(10, "0")

16:06:21.298 [info]  send: {"id":-576460752303423291,"jsonrpc":"2.0","method":"divide","params":[10,"0"]}

16:06:21.301 [info]  receive: {"error":{"code":-32000,"message":"Internal server error"},"id":-576460752303423291,"jsonrpc":"2.0"}

{:error, %{code: -32000, message: "Internal server error"}}

iex(5)> WsClient.message("hello")

16:06:33.817 [info]  send: {"jsonrpc":"2.0","method":"say","params":["hello"]}
:ok
```
