defmodule PhxServer.RemoteProcedureCalls do
  require Logger

  def add(a, b), do: {:ok, a + b}

  def say(text), do: Logger.info("say: #{text}")

  def params(map), do: Map.keys(map)

  def divide(_, 0), do: {:error, -32001, "division by zero"}

  def divide(a, b), do: {:ok, div(a, b)}
end
