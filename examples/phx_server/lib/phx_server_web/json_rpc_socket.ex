defmodule PhxServerWeb.JsonRPCSocket do
  @behaviour Phoenix.Socket.Transport

  alias PhxServer.RemoteProcedureCalls
  alias JsonRPC.HandleRequestError

  require Logger

  def child_spec(_opts) do
    # We won't spawn any process, so let's return a dummy task
    %{id: Task, start: {Task, :start_link, [fn -> :ok end]}, restart: :transient}
  end

  def connect(state) do
    # Callback to retrieve relevant data from the connection.
    # The map contains options, params, transport and endpoint keys.
    {:ok, state}
  end

  def init(state) do
    # Now we are effectively inside the process that maintains the socket.
    {:ok, state}
  end

  def handle_in({json, opts}, state) do
    Logger.info("""
    handle_in:
    json: #{json}
    opts: #{inspect(opts)}\
    """)

    json |> JsonRPC.handle_request(RemoteProcedureCalls) |> IO.inspect() |> response(state)
  rescue
    error in HandleRequestError ->
      error |> JsonRPC.handle_error(message: "Internal server error") |> response(state)
  end

  def handle_info(_, state), do: {:ok, state}

  def terminate(_reason, _state), do: :ok

  defp response(:notification, state), do: {:ok, state}

  defp response(json, state), do: {:reply, :ok, {:text, json}, state}
end
