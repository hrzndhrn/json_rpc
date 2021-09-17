defmodule WsClient.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Supervisor.start_link(children(), opts())
  end

  defp opts do
    [strategy: :one_for_one, name: WsClient.Supervisor]
  end

  defp children do
    [
      {WsClient.Transport, "http://localhost:4000/rpc/websocket"}
    ]
  end
end
