# PhxServer

This example demonstrates how to use `JsonRPC` with a websocket and with a HTTP
API in a phoenix app.

The `PhxServerWeb.JsonRPCSocket` websocket implementation follows the example you
can find in the phoenix documentation for
[Phoenix.Socket.Transport](https://hexdocs.pm/phoenix/Phoenix.Socket.Transport.html#content).

The API controller can be found in `PhxServerWeb.API.JsonRpcController`.

The RPC functions can be found in `PhxServer.RemoteProcedureCalls`.

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
  * The wesocket endpoint: `ws://localhost:4000/rpc/websocket`
  * The API endpoint: `http://localhost:4000/api/rpc`

## Using the example ...

Starting the server:
```shell
iex -S mix phx.server
```

### ... via a websocket

Open the javascript console in your browser and connect to the RPC websocket:
```javascript
> ws = new WebSocket("ws://localhost:4000/rpc/websocket")
```

Setup the `onmessage` callback:
```javascript
> ws.onmessage = (response) => console.log(JSON.parse(response.data))
```

Send an RPCs to the server:
```javascript
> ws.send(JSON.stringify({id: 1, jsonrpc: "2.0", method: "add", params: [1, 2]}))
< {id: 1, jsronrpc: "2.0", result: 3}
> ws.send(JSON.stringify({id: 2, jsonrpc: "2.0", method: "divide", params: [4, 2]}))
< {id: 2, jsronrpc: "2.0", result: 2}
> ws.send(JSON.stringify({id: 3, jsonrpc: "2.0", method: "divide", params: [4, 0]}))
< {id: 3, jsronrpc: "2.0", error: {code: -32001, message: "division by zero"}}
> ws.send(JSON.stringify({id: 4, jsonrpc: "2.0", method: "divide", params: [4, 0]}))
< {id: 4, jsronrpc: "2.0", error: {code: -32000, message: "Internal server error"}}
> ws.send(JSON.stringify({jsonrpc: "2.0", method: "say", params: ["hello"]}))
```

Take a look into the `iex` session:
```elixir
[info] handle_in:
json: %{"id" => 1, "method" => "add", "params" => [1, 2]}
opts: [opcode: :text]
[info] response: {"id":1,"jsonrpc":"2.0","result":3}
...
[info] say: hello
```

### ... via http

The repo contains some scripts using `curl` to call the RPCs.

```shell
$> add.sh 1 2
HTTP/1.1 200 OK
{
   "id" : 1625412051,
   "jsonrpc" : "2.0",
   "result" : 3
}
```

```shell
$> divide.sh 5 2
HTTP/1.1 200 OK
{
   "id" : 1625412563,
   "jsonrpc" : "2.0",
   "result" : 2
}
$> divide.sh 5 0
HTTP/1.1 200 OK
{
   "error" : {
      "code" : -32001,
      "message" : "division by zero"
   },
   "id" : 1626719527,
   "jsonrpc" : "2.0"
}
```

```shell
$> ./say.sh hello
HTTP/1.1 204 No Content
```
