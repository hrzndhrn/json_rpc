defmodule Test.TransportSync do
  @moduledoc false

  @behaviour JsonRPC.Transport

  alias JsonRPC.HandleRequestError
  alias Test.Calls

  require Logger

  @impl true
  def send_rpc(json, _opts) do
    # simulate sending
    with :ok <- mock(json) do
      server(json)
    end
  end

  defp server(json) do
    # simulate a server with pre-decoded JSON
    json
    |> Jason.decode!()
    |> JsonRPC.handle_request(Calls)
    |> response()
  rescue
    error in HandleRequestError ->
      Logger.error(Exception.message(error))
      error |> JsonRPC.handle_error() |> response()
  end

  defp response(:notification), do: :ok

  defp response(json), do: json |> Jason.encode!() |> client()

  defp client(response), do: {:ok, response}

  defp mock(json) do
    cond do
      Regex.match?(~r/method.*invalid_response/, json) ->
        {:ok, "invalid"}

      Regex.match?(~r/method.*send_failed/, json) ->
        {:error, :send_failed}

      Regex.match?(~r/params.*kaput/, json) ->
        {:error, :kaput}

      true ->
        :ok
    end
  end
end
