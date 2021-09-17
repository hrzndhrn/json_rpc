defmodule WsClientTest do
  use ExUnit.Case

  import Prove

  @moduletag :capture_log

  prove WsClient.add(1, 2) == {:ok, 3}

  prove WsClient.divide(12, 3) == {:ok, 4}

  prove WsClient.divide(5, 0) ==
          {:error, %{code: -32001, message: "division by zero"}}

  prove WsClient.params(%{a: 4, b: 5}) == {:ok, ["a", "b"]}

  prove WsClient.params(a: 4, b: 5) == {:ok, ["a", "b"]}

  prove WsClient.message("hello") == :ok
end
