defmodule PhxServerWeb.PageController do
  use PhxServerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
