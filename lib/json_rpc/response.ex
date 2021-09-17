defmodule JsonRPC.Response do
  @moduledoc """
  Representation of a JsonRPC response. The JsonRPC version is always `"2.0"`.

  ## Examples

      iex> JsonRPC.Response.cast(id: 42, result: true)
      {:ok, %JsonRPC.Response{id: 42, jsonrpc: "2.0", result: true}}
  """

  use Xema

  xema do
    field :id, [:number, :string, nil]
    field :jsonrpc, :string, enum: ["2.0"], default: "2.0"
    field :result, :any
    required [:id, :result]
  end
end
