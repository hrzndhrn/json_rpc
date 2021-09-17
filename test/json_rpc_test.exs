defmodule JsonRPCTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Test.Calls
  alias Test.ClientAsync
  alias Test.ClientSync

  doctest JsonRPC
  doctest JsonRPC.ErrorResponse
  doctest JsonRPC.Response
  doctest JsonRPC.Request

  @moduletag timeout: 1_000

  @parse_error -32_700
  @invalid_request -32_600
  @method_not_found -32_601
  @invalid_params -32_602

  describe "functions" do
    test "in client (async)" do
      assert :functions |> ClientAsync.__info__() |> Enum.sort() == [
               __json_rpc_id__: 0,
               add: 2,
               divide: 2,
               hello: 1,
               kaput: 0,
               keys: 1,
               keys_to_list: 1,
               missing: 0,
               msg: 1,
               say: 1,
               say_hello: 1,
               sub: 2,
               subtraction: 2
             ]
    end

    test "in client (sync)" do
      assert :functions |> ClientSync.__info__() |> Enum.sort() == [
               __json_rpc_id__: 0,
               add: 2,
               divide: 2,
               hello: 1,
               invalid_response: 0,
               kaput: 0,
               keys: 1,
               keys_to_list: 1,
               missing: 0,
               msg: 1,
               say: 1,
               say_hello: 1,
               send_failed: 0,
               sub: 2,
               subtraction: 2
             ]
    end
  end

  describe "rpc by_position (sync)" do
    @describetag :sync_tests

    test "with server-function returns ok tuple" do
      assert ClientSync.add(5, 5) == {:ok, 10}
    end

    test "with server-function returns value" do
      assert ClientSync.sub(5, 3) == {:ok, 2}
    end

    test "with delegation" do
      assert ClientSync.subtraction(5, 3) == {:ok, 2}
    end
  end

  describe "rpc by_position (async)" do
    @describetag :async_tests

    test "with server-function returns ok tuple" do
      assert ClientAsync.add(5, 5) == {:ok, 10}
    end

    test "with server-function returns value" do
      assert ClientAsync.sub(5, 3) == {:ok, 2}
    end

    test "with delegation" do
      assert ClientAsync.subtraction(5, 3) == {:ok, 2}
    end
  end

  describe "rpc by_name (sync)" do
    @describetag :sync_tests

    test "with valid params" do
      assert ClientSync.keys(%{"a" => 1, "b" => 2}) == {:ok, ["a", "b"]}
    end

    test "with invalid params" do
      message = "no function clause matching in Test.ClientSync.keys/1"

      assert_raise FunctionClauseError, message, fn ->
        ClientSync.keys(:foo) == {:ok, ["a", "b"]}
      end
    end

    test "with delegate" do
      assert ClientSync.keys_to_list(%{x: 1, y: 2}) == {:ok, ["x", "y"]}
    end

    test "throws ArgumentError" do
      assert_raise ArgumentError, "rpc expects a keyword list or a map", fn ->
        ClientSync.keys([1, 2])
      end
    end
  end

  describe "rpc by_name (async)" do
    test "with valid params" do
      assert ClientAsync.keys(%{"a" => 1, "b" => 2}) == {:ok, ["a", "b"]}
    end

    test "with invalid params" do
      message = "no function clause matching in Test.ClientAsync.keys/1"

      assert_raise FunctionClauseError, message, fn ->
        ClientAsync.keys(:foo) == {:ok, ["a", "b"]}
      end
    end

    test "with delegate" do
      assert ClientAsync.keys_to_list(%{x: 1, y: 2}) == {:ok, ["x", "y"]}
    end
  end

  describe "rpc errors (sync):" do
    @describetag :sync_tests

    test "valid divide call" do
      assert ClientSync.divide(4, 2) == {:ok, 2}
    end

    test "divide by zero" do
      assert ClientSync.divide(4, 0) == {:error, %{code: -3200, message: ""}}
    end

    test "divide with invalid arguments" do
      assert ClientSync.divide(4.0, 1.0) == {
               :error,
               %{code: -3203, message: "Dividend and divisor must be integers."}
             }
    end

    test "divide with invalid dividend" do
      assert ClientSync.divide(4.0, 1) ==
               {:error,
                %{
                  code: -3202,
                  data: %{"dividend" => 4.0},
                  message: "Dividend and divisor must be integers."
                }}
    end

    test "divide with invalid divisor" do
      assert ClientSync.divide(4, 1.0) ==
               {:error,
                %{
                  code: -3201,
                  data: %{"divisor" => 1.0},
                  message: "Dividend and divisor must be integers."
                }}
    end

    test "with missing method" do
      assert ClientSync.missing() ==
               {:error,
                %{
                  code: @method_not_found,
                  message: "Method not found",
                  data: %{"method" => "missing"}
                }}
    end

    test "invalid response" do
      assert ClientSync.invalid_response() == {
               :error,
               {:parse_error, %Jason.DecodeError{data: "invalid", position: 0, token: nil}}
             }
    end

    test "send failed" do
      assert ClientSync.send_failed() == {:error, :send_failed}
    end
  end

  describe "rpc errors (async):" do
    @describetag :async_tests

    test "valid divide call" do
      assert ClientAsync.divide(4, 2) == {:ok, 2}
    end

    test "divide by zero" do
      assert ClientAsync.divide(4, 0) == {:error, %{code: -3200, message: ""}}
    end

    test "divide with invalid arguments" do
      assert ClientAsync.divide(4.0, 1.0) == {
               :error,
               %{code: -3203, message: "Dividend and divisor must be integers."}
             }
    end

    test "divide with invalid dividend" do
      assert ClientAsync.divide(4.0, 1) ==
               {:error,
                %{
                  code: -3202,
                  data: %{"dividend" => 4.0},
                  message: "Dividend and divisor must be integers."
                }}
    end

    test "divide with invalid divisor" do
      assert ClientAsync.divide(4, 1.0) ==
               {:error,
                %{
                  code: -3201,
                  data: %{"divisor" => 1.0},
                  message: "Dividend and divisor must be integers."
                }}
    end

    test "with missing method" do
      assert ClientAsync.missing() ==
               {:error,
                %{
                  code: @method_not_found,
                  message: "Method not found",
                  data: %{"method" => "missing"}
                }}
    end
  end

  describe "notification by_name (sync)" do
    test "with valid param" do
      log =
        capture_log(fn ->
          assert ClientSync.hello(%{name: "world"}) == :ok
        end)

      assert log =~ "[info]  Hello, world!"
    end

    test "with invalid param" do
      message = "no function clause matching in Test.ClientSync.hello/1"

      assert_raise FunctionClauseError, message, fn ->
        ClientSync.hello("mars")
      end
    end

    test "with delegate" do
      log =
        capture_log(fn ->
          assert ClientSync.say_hello(%{name: "world"}) == :ok
        end)

      assert log =~ "[info]  Hello, world!"
    end

    test "returns error tuple" do
      assert ClientSync.hello(%{name: "kaput"}) == {:error, :kaput}
    end
  end

  describe "notification by_name (async)" do
    test "with valid param" do
      log =
        capture_log(fn ->
          notification(fn ->
            assert ClientAsync.hello(%{name: "world"}) == :ok
          end)
        end)

      assert log =~ "[info]  Hello, world!"
    end

    test "with invalid param" do
      message = "no function clause matching in Test.ClientAsync.hello/1"

      assert_raise FunctionClauseError, message, fn ->
        ClientAsync.hello("mars")
      end
    end

    test "with delegate" do
      log =
        capture_log(fn ->
          notification(fn ->
            assert ClientAsync.say_hello(%{name: "world"}) == :ok
          end)
        end)

      assert log =~ "[info]  Hello, world!"
    end
  end

  describe "notification by_position (sync)" do
    test "with valid params" do
      log =
        capture_log(fn ->
          assert ClientSync.say("hello") == :ok
        end)

      assert log =~ "[info]  say: hello"
    end

    test "with delegate" do
      log =
        capture_log(fn ->
          assert ClientSync.msg("hello") == :ok
        end)

      assert log =~ "[info]  say: hello"
    end
  end

  describe "notification by_position (async)" do
    test "with valid params" do
      log =
        capture_log(fn ->
          notification(fn ->
            assert ClientAsync.say("hello") == :ok
          end)
        end)

      assert log =~ "[info]  say: hello"
    end

    test "with delegate" do
      log =
        capture_log(fn ->
          notification(fn ->
            assert ClientAsync.msg("hello") == :ok
          end)
        end)

      assert log =~ "[info]  say: hello"
    end
  end

  describe "handle/1 (server)" do
    setup do
      Application.put_env(:json_rpc, :parser, Poison)

      on_exit(fn ->
        Application.put_env(:json_rpc, :parser, Jason)
      end)
    end

    test "returns an error response for non-parsable json" do
      assert "foo" |> JsonRPC.handle_request(Calls) |> Jason.decode!() == %{
               "jsonrpc" => "2.0",
               "id" => nil,
               "error" => %{
                 "code" => @parse_error,
                 "data" => %{"request" => "\"foo\""},
                 "message" => "unexpected token at position 0: f"
               }
             }
    end

    test "returns an error response for invalid request map" do
      request = %{id: 42, method: "foo", params: 5}

      assert JsonRPC.handle_request(request, Calls) == %{
               error: %{
                 code: -32_600,
                 data: %{request: %{id: 42, method: "foo", params: 5}},
                 message:
                   "Invalid request: cannot cast 5 to any of [:list, :map, nil] at [:params]"
               },
               id: 42,
               jsonrpc: "2.0"
             }
    end

    test "returns an error response for invalid params in request map" do
      request = %{"id" => 42, "method" => "foo", "params" => 5}

      assert JsonRPC.handle_request(request, Calls) == %{
               error: %{
                 code: @invalid_params,
                 data: %{
                   request: %{"id" => 42, "method" => "foo", "params" => 5}
                 },
                 message:
                   "Invalid params: cannot cast 5 to any of [:list, :map, nil] at [\"params\"]"
               },
               id: 42,
               jsonrpc: "2.0"
             }
    end

    test "returns an error response for invalid params in request string" do
      request = Jason.encode!(%{id: 42, method: "foo", params: 5})

      assert request |> JsonRPC.handle_request(Calls) |> Jason.decode!() == %{
               "error" => %{
                 "code" => @invalid_params,
                 "data" => %{"request" => %{"id" => 42, "method" => "foo", "params" => 5}},
                 "message" =>
                   "Invalid params: cannot cast 5 to any of [:list, :map, nil] at [\"params\"]"
               },
               "id" => 42,
               "jsonrpc" => "2.0"
             }
    end

    test "returns an error response for an invalid request map" do
      request = %{"id" => 42, "method" => "foo", "params" => [5], "foo" => 666}

      assert JsonRPC.handle_request(request, Calls) == %{
               error: %{
                 code: @invalid_request,
                 data: %{
                   request: %{"id" => 42, "method" => "foo", "params" => [5], "foo" => 666}
                 },
                 message: """
                 Invalid request: cannot cast %{foo: 666, id: 42, jsonrpc: "2.0", \
                 method: "foo", params: [5]} to JsonRPC.Request, key :foo not found \
                 in JsonRPC.Request\
                 """
               },
               id: 42,
               jsonrpc: "2.0"
             }
    end

    test "returns an error response for an invalid request string" do
      request = Jason.encode!(%{id: 42, method: "foo", params: [5], foo: 666})

      assert request |> JsonRPC.handle_request(Calls) |> Jason.decode!() == %{
               "error" => %{
                 "code" => @invalid_request,
                 "data" => %{
                   "request" => %{"id" => 42, "method" => "foo", "params" => [5], "foo" => 666}
                 },
                 "message" => """
                 Invalid request: cannot cast %{foo: 666, id: 42, jsonrpc: "2.0", \
                 method: "foo", params: [5]} to JsonRPC.Request, key :foo not found \
                 in JsonRPC.Request\
                 """
               },
               "id" => 42,
               "jsonrpc" => "2.0"
             }
    end

    test "returns an error response for a missing method in request map" do
      request = %{"id" => 42, "method" => "xyz", "params" => [5]}

      assert JsonRPC.handle_request(request, Calls) == %{
               error: %{
                 code: -32_601,
                 data: %{method: "xyz"},
                 message: "Method not found"
               },
               id: 42,
               jsonrpc: "2.0"
             }
    end

    test "returns an error response for a missing method in request string" do
      request = Jason.encode!(%{id: 42, method: "xyz", params: [5]})

      assert request |> JsonRPC.handle_request(Calls) |> Jason.decode!() == %{
               "error" => %{
                 "code" => -32_601,
                 "data" => %{"method" => "xyz"},
                 "message" => "Method not found"
               },
               "id" => 42,
               "jsonrpc" => "2.0"
             }
    end
  end

  describe "handle/1 (client)" do
    test "returns error tuple for missing request" do
      assert JsonRPC.handle_response(~s|{"id": 1, "result": 42, "jsonrpc": "2.0"}|) ==
               {:error, :no_request}
    end

    test "returns an error tuple for invalid json" do
      json = ~s|{"id": 1, "foo": xxx}|

      assert JsonRPC.handle_response(json) ==
               {:error, {:parse_error, %Jason.DecodeError{data: json, position: 17, token: nil}}}
    end

    test "returns an error tuple for invalid input" do
      assert JsonRPC.handle_response("{}") == {:error, :invalid_input}
    end

    test "returns an error tuple for invalid response" do
      assert JsonRPC.handle_response(~s|{"result": 5}|) == {
               :error,
               %Xema.CastError{
                 error: nil,
                 key: nil,
                 message: nil,
                 path: [],
                 required: [:id],
                 to: JsonRPC.Response,
                 value: %{"result" => 5}
               }
             }
    end

    test "returns an error tuple for invalid error-response" do
      assert JsonRPC.handle_response(~s|{"error": 5}|) == {
               :error,
               %Xema.CastError{
                 __exception__: true,
                 error: nil,
                 key: nil,
                 message: nil,
                 path: [],
                 required: [:id],
                 to: JsonRPC.ErrorResponse,
                 value: %{"error" => 5}
               }
             }
    end
  end

  describe "use/2" do
    test "creates a client" do
      code = """
      defmodule Test.A.Client do
        use JsonRPC

        rpc foo(a)

        rpc faa(a), params: :by_name

        rpc bar(a), notification: true

        rpc baz(a), notification: true, params: :by_name
      end
      """

      assert {{:module, Test.A.Client, _bin, _bindings}, []} = Code.eval_string(code)
    end
  end

  describe "fallback" do
    test "returns error for a fallback (sync)" do
      log =
        capture_log(fn ->
          assert ClientSync.kaput() ==
                   {:error, %{code: -32_000, message: "** (RuntimeError) kaput"}}
        end)

      assert log =~ "[error] JsonRPC"
    end

    test "returns error for a fallback (async)" do
      assert ClientAsync.kaput() == {:error, %{code: -32_000, message: "Internal server error"}}
    end
  end

  defp notification(fun) do
    Registry.register(JsonRPC.Registry, :test, :notification)

    fun.()

    receive do
      :ready -> :ok
      100 -> {:error, :notification_timeout}
    end
  end
end
