defmodule JsonRPC.UID do
  @moduledoc """
  An implementation of the `JsonRPC.ID` behaviour.

  This module generate a  unique ID with `System.unique_integer/1`.
  """

  @behaviour JsonRPC.ID

  @impl true
  def generate, do: System.unique_integer()
end
