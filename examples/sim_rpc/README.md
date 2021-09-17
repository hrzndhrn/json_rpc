# SimRPC

SimRPC is a simple example that simulates the sending of a JsonRPC.

The example contains two clients, a server, and a transport module.
The `SimRPC.Transport` module simulates the sending of a message for the
`SimRPC.Client` and `SimRPC.ClientSync`. In the case of `SimRPC.Client`, the
sending of an RPC is simulated by spawning a new process.

## Using the example

The expected outputs for `SimRPC.Client` and `SimRPC.ClientSync` are equal
excepts for the `id`s.

Starting the example:
```shell
iex -S mix
```

Using an RPC:
```elixir

iex(1)> SimRPC.Client.add(1, 2)

19:35:44.645 [info]  send:
"{\"id\":-576460752303423421,\"jsonrpc\":\"2.0\",\"method\":\"add\",\"params\":[1,2]}"

19:35:44.648 [info]  client opts:
[parser: JsonRPC.JasonParser, transport: SimRPC.Transport]

19:35:44.654 [info]  receive:
"{\"id\":-576460752303423421,\"jsonrpc\":\"2.0\",\"result\":3}"

{:ok, 3}
```

Using an RPC notification:
```elixir
iex(2)> SimRPC.Client.msg("hello")

19:36:46.042 [info]  send:
"{\"jsonrpc\":\"2.0\",\"method\":\"msg\",\"params\":[\"hello\"]}"

19:36:46.042 [info]  client opts:
[parser: JsonRPC.JasonParser, transport: SimRPC.Transport]

19:36:46.042 [info]  hello

:ok
```

Using a delegate:
```elixir
iex(3)> SimRPC.Client.message("hello")

19:37:44.239 [info]  send:
"{\"jsonrpc\":\"2.0\",\"method\":\"msg\",\"params\":[\"hello\"]}"

19:37:44.239 [info]  client opts:
[parser: JsonRPC.JasonParser, transport: SimRPC.Transport]

19:37:44.239 [info]  hello

:ok
```

Receiving an error:
```elixir
iex(4)> SimRPC.Client.divide(5, 0)

19:39:02.752 [info]  send:
"{\"id\":-576460752303423357,\"jsonrpc\":\"2.0\",\"method\":\"divide\",\"params\":[5,0]}"

19:39:02.752 [info]  client opts:
[parser: JsonRPC.JasonParser, transport: SimRPC.Transport]

19:39:02.754 [info]  receive:
"{\"error\":{\"code\":-32001,\"message\":\"division by zero\"},\"id\":-576460752303423357,\"jsonrpc\":\"2.0\"}"

{:error, %{code: -32001, message: "division by zero"}}
```

Receiving an internal error:
```elixir
iex(5)> SimRPC.Client.divide(5, "0")

19:40:21.479 [info]  send:
"{\"id\":-576460752303423293,\"jsonrpc\":\"2.0\",\"method\":\"divide\",\"params\":[5,\"0\"]}"

19:40:21.479 [info]  client opts:
[parser: JsonRPC.JasonParser, transport: SimRPC.Transport]

19:40:21.487 [error] JsonRPC with id -576460752303423293 fails
  method: "divide"
  params: [5, "0"]
  reason: ** (ArithmeticError) bad argument in arithmetic expression


19:40:21.487 [info]  receive:
"{\"error\":{\"code\":-32000,\"message\":\"Internal server error\"},\"id\":-576460752303423293,\"jsonrpc\":\"2.0\"}"

{:error, %{code: -32000, message: "Internal server error"}}
```

Calling a by-name RPC:
```elixir
iex(6)> SimRPC.Client.params(a: 0, b: 1)

19:41:02.958 [info]  send:
"{\"id\":-576460752303423229,\"jsonrpc\":\"2.0\",\"method\":\"params\",\"params\":{\"a\":0,\"b\":1}}"

19:41:02.958 [info]  client opts:
[parser: JsonRPC.JasonParser, transport: SimRPC.Transport]

19:41:02.958 [info]  receive:
"{\"id\":-576460752303423229,\"jsonrpc\":\"2.0\",\"result\":[\"a\",\"b\"]}"

{:ok, ["a", "b"]}
```
