defmodule JsonRPC.Handler do
  @moduledoc false

  alias JsonRPC.ErrorResponse
  alias JsonRPC.Json
  alias JsonRPC.Request
  alias JsonRPC.Response
  alias JsonRPC.Transport
  alias Xema.CastError

  require Logger

  @registry JsonRPC.Registry
  @default_error_code -32_000

  def remote(%Request{id: :notification} = request, opts) do
    case send_rpc(request, opts) do
      :ok -> :ok
      {:ok, :notification} -> :ok
      {:error, _reason} = error -> error
    end
  end

  def remote(%Request{} = request, opts) do
    {:ok, _pid} = Registry.register(@registry, request.id, nil)

    case send_rpc(request, opts) do
      :ok ->
        async(opts)

      sync ->
        Registry.unregister(@registry, request.id)
        handle_response(sync, false)
    end
  end

  def handle_response(input) do
    handle_response(input, true)
  end

  defp handle_response({:ok, json}, async) do
    with {:ok, response} <- response(json) do
      case async do
        true -> send_response(response)
        false -> unpack(response)
      end
    end
  end

  defp handle_response({:error, _reason} = error, _async), do: error

  def handle_request(request, module) do
    handle_request(request, module, nil)
  end

  defp handle_request(%Request{} = request, module, from) do
    case call(request, module) do
      {:ok, {fun, args}} ->
        module |> apply(fun, args) |> result(request) |> to(from)

      error ->
        error |> error(request) |> to(from)
    end
  rescue
    exception ->
      reraise JsonRPC.HandleRequestError,
              [reason: exception, request: request, from: from],
              __STACKTRACE__
  end

  defp handle_request(json, module, _from) when is_binary(json) do
    case Json.decode(json) do
      {:ok, map} ->
        handle_request(map, module, :binary)

      error ->
        error |> error(json) |> to(:binary)
    end
  end

  defp handle_request(json, module, from) when is_map(json) do
    case Request.cast(json) do
      {:ok, request} ->
        handle_request(request, module, from || :map)

      error ->
        error |> error(json) |> to(from || :map)
    end
  end

  def handle_error(%{request: request, reason: reason, from: to}, opts) do
    error = [code: @default_error_code, message: Exception.format(:error, reason)]
    error_response = ErrorResponse.cast!(id: request.id, error: Keyword.merge(error, opts))

    case to do
      :map -> Map.from_struct(error_response)
      :binary -> error_response |> Map.from_struct() |> Json.encode!()
    end
  end

  defp async(opts) do
    timeout = Keyword.get(opts, :timeout, 10_000)

    receive do
      response ->
        Registry.unregister(@registry, response.id)
        unpack(response)
    after
      timeout -> {:error, :timeout}
    end
  end

  defp send_rpc(%Request{} = request, opts) do
    request |> Request.to_map() |> Json.encode!() |> Transport.send_rpc(opts)
  end

  defp send_response(%module{id: id} = response)
       when module in [Response, ErrorResponse] do
    case Registry.lookup(@registry, id) do
      [{pid, nil}] ->
        send(pid, response)
        :ok

      [] ->
        {:error, :no_request}
    end
  end

  defp response(json) when is_binary(json) do
    with {:ok, input} <- Json.decode(json) do
      to_struct(input, :response)
    end
  end

  defp unpack(%Response{result: result}), do: {:ok, result}

  defp unpack(%ErrorResponse{error: error}), do: {:error, error}

  defp to_struct(%{"result" => _result} = input, :response), do: Response.cast(input)

  defp to_struct(%{"error" => _error} = input, :response), do: ErrorResponse.cast(input)

  defp to_struct(_input, _expected), do: {:error, :invalid_input}

  defp to(:notification, _from), do: :notification

  defp to(result, :map), do: result |> Map.from_struct()

  defp to(result, :binary), do: result |> Map.from_struct() |> Json.encode!()

  defp result(_, %Request{id: :notification}), do: :notification

  defp result({:error, code}, %Request{} = request) when is_integer(code) do
    error(code, "", nil, request)
  end

  defp result({:error, code, message}, %Request{} = request)
       when is_integer(code) and is_binary(message) do
    error(code, message, nil, request)
  end

  defp result({:error, code, message, data}, %Request{} = request)
       when is_integer(code) and is_binary(message) do
    error(code, message, data, request)
  end

  defp result({:ok, value}, %Request{} = request), do: ok(value, request)

  defp result(value, %Request{} = request), do: ok(value, request)

  defp ok(value, request), do: Response.cast!(id: request.id, result: value)

  defp error({:error, {:parse_error, error}}, request) do
    error(-32_700, Exception.message(error), %{request: inspect(request)}, nil)
  end

  defp error({:error, :method_not_found}, %Request{method: method} = request) do
    error(-32_601, "Method not found", %{method: method}, request)
  end

  defp error({:error, %CastError{path: ["params"]} = error}, request) do
    error(-32_602, "Invalid params: #{Exception.message(error)}", %{request: request}, request)
  end

  defp error({:error, %CastError{} = error}, request) do
    error(-32_600, "Invalid request: #{Exception.message(error)}", %{request: request}, request)
  end

  defp error(code, message, nil, request) do
    ErrorResponse.cast!(id: id(request), error: [code: code, message: message])
  end

  defp error(code, message, data, request) do
    ErrorResponse.cast!(id: id(request), error: [code: code, message: message, data: data])
  end

  defp id(input) do
    case input do
      %Request{id: id} -> id
      %{"id" => id} -> id
      %{id: id} -> id
      _else -> nil
    end
  end

  defp call(%Request{method: method, params: params}, module) do
    args = args(params)

    with :ok <- loaded(module),
         {:ok, fun} <- fun(method) do
      case function_exported?(module, fun, length(args)) do
        true -> {:ok, {fun, args}}
        false -> {:error, :method_not_found}
      end
    end
  end

  defp fun(method) do
    {:ok, String.to_existing_atom(method)}
  rescue
    _error -> {:error, :method_not_found}
  end

  defp loaded(module) do
    case Code.ensure_loaded(module) do
      {:module, _module} -> :ok
      _error -> {:error, :method_not_found}
    end
  end

  defp args(nil), do: []

  defp args(params) when is_map(params), do: [params]

  defp args(params) when is_list(params), do: params
end
