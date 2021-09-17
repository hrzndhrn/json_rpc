defmodule JsonRPC.ID do
  @moduledoc """
  An ID generator.
  """

  @doc """
  Returns an ID.
  """
  @callback generate :: String.t() | integer()

  defmacro __using__(impl: impl) do
    quote do
      def __json_rpc_id__, do: unquote(impl).generate()
    end
  end
end
