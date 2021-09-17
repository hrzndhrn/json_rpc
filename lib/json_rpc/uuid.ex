if match?({:module, _module}, Code.ensure_compiled(UUID)) do
  defmodule JsonRPC.UUID do
    @moduledoc """
    An implementation of the `JsonRPC.ID` behaviour.

    This module generate a version 4 UUID.
    """

    @behaviour JsonRPC.ID

    @impl true
    def generate, do: UUID.uuid4(:hex)
  end
end
