defmodule JsonRPC.HandleRequestError do
  defexception [:from, :reason, :request]

  @doc false
  def message(%{request: request, reason: reason}) do
    """
    JsonRPC with id #{request.id} fails
      method: #{inspect(request.method)}
      params: #{inspect(request.params)}
      reason: #{Exception.format(:error, reason)}
    """
  end
end
