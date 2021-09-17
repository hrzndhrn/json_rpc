defmodule JsonRPC.UIDTest do
  use ExUnit.Case

  alias JsonRPC.UID

  test "generate" do
    assert is_integer(UID.generate())
  end
end
