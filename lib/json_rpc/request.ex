defmodule JsonRPC.Request do
  @moduledoc """
  Representation of a JsonRPC request. The JsonRPC version is always `"2.0"`.

  ## Examples

      iex> JsonRPC.Request.cast(id: "x-1", method: "say", params: ["hello"])
      {:ok, %JsonRPC.Request{id: "x-1", jsonrpc: "2.0", method: "say", params: ["hello"]}}

      iex> JsonRPC.Request.cast(method: "beat")
      {:ok, %JsonRPC.Request{id: :notification, jsonrpc: "2.0", method: "beat", params: nil}}
  """

  use Xema

  xema do
    field :id, [:atom, :number, :string, nil], default: :notification
    field :jsonrpc, :string, enum: ["2.0"], default: "2.0"
    field :method, :string
    field :params, [:list, :map, nil]
    required [:method]
  end

  @doc """
  Converts a request to map.

  The `id` is omitted when the value is `:notification`. `params` is ommitted
  when it is `nil`.

  ## Examples

      iex> JsonRPC.Request.to_map(
      ...>   %JsonRPC.Request{id: "x-1", jsonrpc: "2.0", method: "say", params: ["hello"]})
      %{id: "x-1", jsonrpc: "2.0", method: "say", params: ["hello"]}

      iex> JsonRPC.Request.to_map(
      ...>   %JsonRPC.Request{id: :notification, jsonrpc: "2.0", method: "beat", params: nil})
      %{jsonrpc: "2.0", method: "beat"}
  """
  @spec to_map(%__MODULE__{}) :: map()
  def to_map(%__MODULE__{} = request) do
    %{jsonrpc: request.jsonrpc, method: request.method}
    |> put(:params, request.params)
    |> put(:id, request.id)
  end

  defp put(map, :params, nil), do: map
  defp put(map, :params, value), do: Map.put(map, :params, value)

  defp put(map, :id, :notification), do: map
  defp put(map, :id, value), do: Map.put(map, :id, value)
end
