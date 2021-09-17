defmodule JsonRPC.Transport do
  @moduledoc """
  The transport layer to send a JSON RPC to a server.
  """

  @doc """
  Sends the given `json_rpc` to a server.

  This function gets the encoded JSON-RPC and the options of the client as
  arguments.

  Returning `:ok` indicates an asynchronous call or a notification in a
  synchronous workflow. In an asynchronous workflow the function
  `JsonRPC.handle_response/1` must be called with the response from the server.

  Returning `{:ok, response}` runs the request/response loop with the JSON-RPC
  response in the tuple.

  Returning `{:error, reason}` returns an error to the caller of the RPC.
  """
  @callback send_rpc(json_rpc :: String.t(), opts :: keyword()) ::
              :ok | {:ok, :notification} | {:ok, binary()} | {:error, term()}

  @doc false
  @spec send_rpc(String.t(), keyword()) ::
          :ok | {:ok, :notification} | {:ok, binary()} | {:error, term()}
  def send_rpc(json, opts) do
    implementation(opts).send_rpc(json, opts)
  end

  defp implementation(opts), do: Keyword.fetch!(opts, :transport)
end
