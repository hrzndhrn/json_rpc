defmodule HttpClientTest do
  use ExUnit.Case

  import Prove

  @moduletag :capture_log

  prove HttpClient.add(1, 2) == {:ok, 3}

  prove HttpClient.divide(12, 3) == {:ok, 4}

  prove HttpClient.divide(5, 0) ==
          {:error, %{code: -32001, message: "division by zero"}}

  prove HttpClient.params(%{a: 4, b: 5}) == {:ok, ["a", "b"]}

  prove HttpClient.params(a: 4, b: 5) == {:ok, ["a", "b"]}

  prove HttpClient.message("hello") == :ok
end
