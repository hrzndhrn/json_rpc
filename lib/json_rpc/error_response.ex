defmodule JsonRPC.ErrorResponse do
  @moduledoc """
  Representation of a JsonRPC error response. The JsonRPC version is always `"2.0"`.

  ## Examples

      iex> JsonRPC.ErrorResponse.cast(id: 42, error: %{code: -32001, message: "invalid"})
      {:ok,
        %JsonRPC.ErrorResponse{
          id: 42, jsonrpc: "2.0", error: %{code: -32001, message: "invalid"}
        }
      }
  """

  use Xema

  xema do
    field :id, [:number, :string, nil]
    field :jsonrpc, :string, enum: ["2.0"], default: "2.0"

    field :error, :map,
      keys: :atoms,
      properties: %{
        code: :integer,
        message: :string,
        data: :any
      },
      addition_properties: false,
      required: [:code, :message]

    required [:id, :error]
  end
end
