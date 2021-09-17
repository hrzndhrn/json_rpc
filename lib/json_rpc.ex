defmodule JsonRPC do
  @moduledoc """
  A module to create JSON-RPC clients and handle JSON-RPC requests.

  For more information to JSON-RPC 2.0 see the
  [specification](https://www.jsonrpc.org/specification).

  `JsonRPC` comes without any code to sending the generated JSON-RPCs. For the
  transport the behaviour `JsonRPC.Transport` has to be used.

  `JsonRPC` uses `jason` per default. To customize the JSON library, including the
  following in your config:
  ```elixir
  config :json_rpc, parser: :poison
  ```

  ## Client

  A client can be written by using `JsonRPC`.

  ```elixir
  defmodule Example.Client do
    use JsonRPC, transport: Example.Transport

    rpc add(a, b)

    rpc msg(text), notification: true

    rpc message(text), notification: true, delegate: "msg"

    rpc params(map), params: :by_name
  end
  ```
  The module `Example.Client` contains now the functions `add/2`, `msg/1`,
  `message/1` and `params/1`. When one of this function will be called a
  JSON-RPC will be generated and `Example.Transport.send_rpc/2` will be called.
  The first argument of `Transport.send_rpc/2` is the encoded JSON-RPC and the
  second argument are the options given to `JsonRPC`.

  See `Transport.send_rpc` for more information.

  See `rpc/2` for more information about the options.

  ## Server

  A server has to use the function `handle_request/2`.
  """

  alias JsonRPC.Handler
  alias JsonRPC.HandleRequestError
  alias JsonRPC.Request

  @type json :: binary() | map()

  defmacro __using__(opts) do
    quote do
      use JsonRPC.ID, impl: Keyword.get(unquote(opts), :id, JsonRPC.UID)

      import JsonRPC

      Module.put_attribute(__MODULE__, :json_rpc_opts, defaults(unquote(opts)))
    end
  end

  @doc """
  Defines a RPC with the given name and arguments.

  Options:
  - `:notification` - a boolean to mark a RPC as a notification, defaults to
    `false`
  - `:params` - treat arguments either as `:by_position` or `:by_name`, defaults
    to `:by_position`. The RPC expected a keyword list or a map when
    `params: :by_name` is set
  - `:delegate` - a string that overrides the RPC name
  """
  defmacro rpc(expr, opts \\ []) do
    rpc(call_type(opts), params_type(opts), expr, delegate(opts))
  end

  @doc """
  Handles the given `json` response.

  The response must contain an `id` from a previously sent request. This
  function is usually used in an asynchronous `JsonRPC.Transport` implementation.
  """
  @spec handle_response(json()) :: :ok | {:error, :no_request} | {:error, term()}
  def handle_response(json) when is_binary(json) do
    Handler.handle_response({:ok, json})
  end

  @doc """
  Handles the given `json` request and executes the corresponding function on
  the given `module`.

  The function returns the result of the called function as an JSON-RPC
  response.

  If the given request encoded JSON, the result is also encoded JSON, and for a
  decoded request, a decode response is returned.

  For a notification (a request without id) the function returns `:notification`.

  `handle_request/2` catches exceptions raised by the called function and raises
  a `JsonRPC.HandleRequestError`. This error could be handled with
  `handle_error/2`.

  ## Examples

      iex> defmodule Math do
      ...>   def add(a, b), do: a + b
      ...> end
      iex> request = %{id: "id-1", jsonrpc: "2.0", method: "add", params: [1, 2]}
      iex> JsonRPC.handle_request(request, Math)
      %{id: "id-1", jsonrpc: "2.0", result: 3}
      iex> JsonRPC.handle_request(Jason.encode!(request), Math)
      ~s|{"id":"id-1","jsonrpc":"2.0","result":3}|
      iex> request = %{id: "id-2", jsonrpc: "2.0", method: "unknown", params: [1, 2]}
      iex> JsonRPC.handle_request(request, Math)
      %{
        id: "id-2",
        error: %{
          code: -32601,
          data: %{method: "unknown"},
          message: "Method not found"
        },
        jsonrpc: "2.0"
      }
  """
  @spec handle_request(json(), module()) :: :notification | json()
  def handle_request(json, module) do
    Handler.handle_request(json, module)
  end

  @doc """
  Handles the given `HandleRequestError`.

  This function generates a JSON-RPC error response for the given `error`.
  The optional `opts` can overwrite the values for `:code` and `:message`.

  ## Examples

      iex> defmodule Mod do
      ...>   def carp, do: raise RuntimeError, "no!"
      ...> end
      iex> request = %{id: 3, jsonrpc: "2.0", method: "carp", params: []}
      iex> try do
      ...>   JsonRPC.handle_request(request, Mod)
      ...> rescue
      ...>   error in JsonRPC.HandleRequestError ->
      ...>     JsonRPC.handle_error(error)
      ...> end
      %{
        id: 3,
        error: %{code: -32000, message: "** (RuntimeError) no!"},
        jsonrpc: "2.0"
      }
  """
  @spec handle_error(%HandleRequestError{}, keyword()) :: json()
  def handle_error(%HandleRequestError{} = error, opts \\ []) when is_list(opts) do
    Handler.handle_error(error, opts)
  end

  @doc false
  def check_by_name(_params, :by_position), do: :ok

  def check_by_name([map], :by_name) when is_map(map), do: :ok

  def check_by_name(_params, :by_name), do: {:error, :invalid_params}

  @doc false
  def rpc(:call, :by_position, {name, meta, params}, delegate) do
    quote do
      def unquote({name, meta, params}) do
        Handler.remote(
          Request.cast!(
            id: __json_rpc_id__(),
            method: unquote(delegate || name),
            params: unquote(params)
          ),
          @json_rpc_opts
        )
      end
    end
  end

  def rpc(:call, :by_name, {name, _meta, [param]} = expr, delegate) do
    quote do
      def unquote(expr) when is_map(unquote(param)) or is_list(unquote(param)) do
        params =
          case is_list(unquote(param)) do
            false ->
              unquote(param)

            true ->
              case Keyword.keyword?(unquote(param)) do
                true -> Enum.into(unquote(param), %{})
                false -> raise ArgumentError, "rpc expects a keyword list or a map"
              end
          end

        Handler.remote(
          Request.cast!(
            id: __json_rpc_id__(),
            method: unquote(delegate || name),
            params: params
          ),
          @json_rpc_opts
        )
      end
    end
  end

  def rpc(:notification, :by_position, {name, _meta, params} = expr, delegate) do
    quote do
      def unquote(expr) do
        Handler.remote(
          Request.cast!(
            method: unquote(delegate || name),
            params: unquote(params)
          ),
          @json_rpc_opts
        )
      end
    end
  end

  def rpc(:notification, :by_name, {name, _meta, [param]} = expr, delegate) do
    quote do
      def unquote(expr) when is_map(unquote(param)) do
        Handler.remote(
          Request.cast!(
            method: unquote(delegate || name),
            params: unquote(param)
          ),
          @json_rpc_opts
        )
      end
    end
  end

  @doc false
  def call_type(opts) do
    case Keyword.get(opts, :notification, false) do
      false -> :call
      true -> :notification
    end
  end

  @doc false
  def params_type(opts), do: Keyword.get(opts, :params, :by_position)

  @doc false
  def delegate(opts), do: Keyword.get(opts, :delegate)

  @doc false
  def defaults(opts) do
    Keyword.put_new(opts, :parser, JsonRPC.JasonParser)
  end
end
