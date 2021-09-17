defmodule SimRPC.Calls do
  require Logger

  def add(a, b), do: a + b

  def divide(_, 0), do: {:error, -32001, "division by zero"}

  def divide(a, b), do: {:ok, div(a, b)}

  def msg(text), do: Logger.info(text)

  def params(map), do: map |> Map.keys() |> Enum.sort()
end
