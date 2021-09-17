defmodule JsonRPC.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Supervisor.start_link(children(), opts())
  end

  defp children do
    [
      {Registry, keys: :unique, name: JsonRPC.Registry}
    ]
  end

  defp opts do
    [strategy: :one_for_one, name: JsonRPC.Supervisor]
  end
end
