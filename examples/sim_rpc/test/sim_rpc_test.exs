defmodule SimRpcTest do
  use ExUnit.Case

  import Prove

  alias SimRPC.Client
  alias SimRPC.ClientSync

  @moduletag :capture_log

  prove Client.add(1, 2) == {:ok, 3}

  prove ClientSync.add(1, 2) == {:ok, 3}

  prove Client.divide(4, 2) == {:ok, 2}

  prove ClientSync.divide(4, 2) == {:ok, 2}

  prove Client.divide(4, 0) == {:error, %{code: -32001, message: "division by zero"}}

  prove ClientSync.divide(4, 0) == {:error, %{code: -32001, message: "division by zero"}}

  prove Client.divide(4, "2") ==
          {:error, %{code: -32000, message: "Internal server error"}}

  prove ClientSync.divide(4, "2") ==
          {:error, %{code: -32000, message: "Internal server error"}}

  prove Client.msg("hello") == :ok

  prove ClientSync.msg("hello") == :ok

  prove Client.params(%{a: 1, b: 2}) == {:ok, ["a", "b"]}

  prove ClientSync.params(%{a: 1, b: 2}) == {:ok, ["a", "b"]}

  prove Client.params(a: 1, b: 2) == {:ok, ["a", "b"]}

  prove ClientSync.params(a: 1, b: 2) == {:ok, ["a", "b"]}
end
