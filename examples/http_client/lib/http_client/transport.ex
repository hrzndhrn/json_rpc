defmodule HttpClient.Transport do
  require Logger

  @behaviour JsonRPC.Transport

  @url "http://localhost:4000/api/rpc"
  @headers [{"content-type", "application/json"}]

  @impl true
  def send_rpc(json, _opts) do
    Logger.info("send: #{json}")

    case HTTPoison.post(@url, json, @headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Logger.info("response: #{body}")
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: 204}} ->
        :ok

      {:ok, response} ->
        {:error, {:unexpected_response, response}}

      {:error, _reason} = error ->
        error
    end
  end
end
