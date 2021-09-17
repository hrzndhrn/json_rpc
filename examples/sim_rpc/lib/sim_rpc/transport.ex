defmodule SimRPC.Transport do
  @moduledoc false

  @behaviour JsonRPC.Transport

  alias JsonRPC.HandleRequestError
  alias SimRPC.Calls

  require Logger

  @impl true
  def send_rpc(json, opts) do
    info("send: ", json)
    info("client opts:", opts)

    # simulate sending
    case Keyword.get(opts, :async, true) do
      true -> async(json)
      false -> sync(json)
    end
  end

  defp sync(json) do
    result = JsonRPC.handle_request(json, Calls)
    info("result: ", result)
    # The result can be a result-object, an error-object or :notification.
    # In case of an error an error tuple {:error, reason} can be returned.
    {:ok, result}
  rescue
    error in HandleRequestError ->
      Logger.error(message: Exception.message(error))
      {:ok, JsonRPC.handle_error(error, message: "Internal server error")}
  end

  defp async(json) do
    Process.spawn(__MODULE__, :do_async, [json], [])
    :ok
  end

  def do_async(json) do
    json |> JsonRPC.handle_request(Calls) |> response()
  rescue
    error in HandleRequestError ->
      Logger.error(Exception.message(error))
      error |> JsonRPC.handle_error(message: "Internal server error") |> response()
  end

  defp response(:notification), do: :ok

  defp response(json) do
    info("receive: ", json)
    JsonRPC.handle_response(json)
  end

  defp info(msg, data), do: Logger.info("#{msg}\n#{inspect(data, pretty: true)}")
end
