defmodule JsonRPC.Json do
  @moduledoc false

  @spec encode!(term()) :: String.t()
  def encode!(input) do
    parser().encode!(input)
  end

  @spec decode(iodata()) :: {:ok, map()} | {:error, {:parse_error, Exception.t()}}
  def decode(json) do
    with {:error, error} <- parser().decode(json) do
      {:error, {:parse_error, error}}
    end
  end

  defp parser, do: Application.get_env(:json_rpc, :parser)
end
