# HttpClient

This example shows a `JsonRPC` HTTP client.

The client calls procedures on the [/examples/phx_server](/examples/phx_server).

## Using the example

Starting the server in [/examples/phx_server](/examples/phx_server).

Starting the client:
```shell
iex -S mix
```

Call the RPCs:
```elixir
iex(1)> HttpClient.add(1, 2)

10:03:08.752 [info]  send: {"id":-576460752303418109,"jsonrpc":"2.0","method":"add","params":[1,2]}

10:03:08.818 [info]  response: {"id":-576460752303418109,"jsonrpc":"2.0","result":3}

{:ok, 3}

iex(2)> HttpClient.divide(10, 2)

10:03:25.362 [info]  send: {"id":-576460752303416735,"jsonrpc":"2.0","method":"divide","params":[10,2]}

10:03:25.398 [info]  response: {"id":-576460752303416735,"jsonrpc":"2.0","result":5}

{:ok, 5}

iex(3)> HttpClient.divide(10, 0)

10:03:27.983 [info]  send: {"id":-576460752303416671,"jsonrpc":"2.0","method":"divide","params":[10,0]}

10:03:28.021 [info]  response: {"error":{"code":-32001,"message":"division by zero"},"id":-576460752303416671,"jsonrpc":"2.0"}

{:error, %{code: -32001, message: "division by zero"}}

iex(4)> HttpClient.divide(10, "2")

10:03:32.531 [info]  send: {"id":-576460752303416607,"jsonrpc":"2.0","method":"divide","params":[10,"2"]}

10:03:32.570 [info]  response: {"error":{"code":-32000,"message":"Internal server error"},"id":-576460752303416607,"jsonrpc":"2.0"}

{:error, %{code: -32000, message: "Internal server error"}}

iex(5)> HttpClient.message("hello")

10:03:44.466 [info]  send: {"jsonrpc":"2.0","method":"say","params":["hello"]}
:ok
```
