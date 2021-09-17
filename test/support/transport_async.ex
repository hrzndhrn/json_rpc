defmodule Test.TransportAsync do
  @moduledoc false

  @behaviour JsonRPC.Transport

  alias JsonRPC.HandleRequestError
  alias Test.Calls

  @impl true
  def send_rpc(json, _opts) do
    # simulate sending
    Process.spawn(__MODULE__, :request, [json], [])
    :ok
  end

  def request(json) do
    # simulate a server
    json |> JsonRPC.handle_request(Calls) |> response()
  rescue
    error in HandleRequestError ->
      # error |> IO.inspect() |> HandleRequestError.to_json("Internal server error") |> response()
      error |> JsonRPC.handle_error(message: "Internal server error") |> response()
  end

  defp response(:notification) do
    # stop notification tests
    case Registry.lookup(JsonRPC.Registry, :test) do
      [{pid, _value}] -> send(pid, :ready)
      [] -> :ok
    end
  end

  defp response(response) do
    # back on the client
    JsonRPC.handle_response(response)
  end
end
