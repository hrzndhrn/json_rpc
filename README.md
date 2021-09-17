# JsonRPC
[![Hex.pm](https://img.shields.io/hexpm/v/json_rpc.svg?style=flat-square)](https://hex.pm/packages/json_rpc)
![Hex.pm](https://img.shields.io/hexpm/dt/json_rpc?style=flat-square)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/hrzndhrn/json_rpc/CI?style=flat-square)
![Coveralls](https://img.shields.io/coveralls/github/hrzndhrn/json_rpc?style=flat-square)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)

An implementation of the [JSON RPC](https://www.jsonrpc.org/) protocol version 2.

This library provides functions to generate and handle JSON RPC requests,
responses and error responses. For the transport of the generate RPC data the
`behaviour` `JsonRPC.Transport` must be implemented.

## Installation

The package can be installed by adding `json_rpc` to your list of dependencies
in `mix.exs`:

```elixir
def deps do
  [
    {:json_rpc, "~> 0.1"}
    # {:jason, "~> 1.2"}
    # {:poison, "~> 5.0"}
  ]
end
```

`JsonRPC` uses `jason` per default. To customize the JSON library, including the
following in your config:
```elixir
config :json_rpc, parser: :poison
```


## Examples

This repo contains some examples of how to us `JsonRPC`.

- [SimRpc](examples/sim_rpc) shows the usage with a "simulated" server. Similar
  to the example in section Usage.
- [phx_server](examples/phx_server) shows a server implementation with a HTTP
  endpoint and a WebSocket.
- [http_client](examples/http_client) shows a HTTP client that communicates with
  the example server implemented in [phx_server](examples/phx_server)
- [ws_client](examples/ws_client) shows a WebSocket client that communicates with
  the example server implemented in [phx_server](examples/phx_server)

## Usage

A quick simple example, for more information see the
[documentation](https://hexdocs.pm/xema/readme.html) and the examples.

A client:
```elixir
defmodule Client do
  use JsonRPC, transport: Transport

  rpc add(a, b)
end
```
An implementation of the behaviour `JsonRPC.Transport`:
```elixir
defmodule Transport do
  @behaviour JsonRPC.Transport

  @impl
  def send_rpc(json, _opts) do
    Process.spawn(Transport, :server, [json], [])
    :ok
  end

  def server(json) do
    json
    |> JsonRPC.handle_request(Math)
    |> JsonRPC.handle_response()
  end
end
```
The module containing the function to be called:
```elixir
defmodule Math do
  def add(a, b), do: a + b
end
```
Using the client:
```elixir
iex> Client.add(1, 2)
{:ok, 3}
```
