defmodule Test.Calls do
  @moduledoc false

  require Logger

  def add(a, b) when is_integer(a) and is_integer(b) do
    {:ok, a + b}
  end

  def sub(a, b), do: a - b

  def divide(_, 0), do: {:error, -3200}

  def divide(a, b) when is_integer(a) and is_integer(b), do: {:ok, div(a, b)}

  def divide(a, x) when is_integer(a),
    do: {:error, -3201, "Dividend and divisor must be integers.", %{divisor: x}}

  def divide(x, a) when is_integer(a),
    do: {:error, -3202, "Dividend and divisor must be integers.", %{dividend: x}}

  def divide(_, _), do: {:error, -3203, "Dividend and divisor must be integers."}

  def keys(map), do: Map.keys(map)

  def hello(%{"name" => name}) do
    Logger.info("Hello, #{name}!")
  end

  def say(msg) do
    Logger.info("say: #{msg}")
  end

  def kaput, do: raise("kaput")
end
