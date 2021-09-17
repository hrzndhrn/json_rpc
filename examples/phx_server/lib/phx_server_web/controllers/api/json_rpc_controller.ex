defmodule PhxServerWeb.API.JsonRpcController do
  use PhxServerWeb, :controller

  alias JsonRPC.HandleRequestError
  alias PhxServer.RemoteProcedureCalls

  def cmd(conn, params) do
    params |> JsonRPC.handle_request(RemoteProcedureCalls) |> response(conn)
  rescue
    error in HandleRequestError ->
      error |> JsonRPC.handle_error(message: "Internal server error") |> response(conn)
  end

  defp response(:notification, conn), do: send_resp(conn, 204, "")

  defp response(term, conn), do: json(conn, term)
end
