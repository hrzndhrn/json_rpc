defmodule WsClient.Transport do
  use WebSockex

  require Logger

  @behaviour JsonRPC.Transport

  def start_link(url, state \\ []) do
    WebSockex.start_link(url, __MODULE__, state, name: __MODULE__)
  end

  @impl WebSockex
  def handle_frame({_type, json}, state) do
    Logger.info("receive: #{json}")

    JsonRPC.handle_response(json)

    {:ok, state}
  end

  @impl JsonRPC.Transport
  def send_rpc(json, _opts) do
    Logger.info("send: #{json}")

    WebSockex.send_frame(__MODULE__, {:text, json})
  end
end
