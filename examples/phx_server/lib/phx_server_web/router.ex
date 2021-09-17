defmodule PhxServerWeb.Router do
  use PhxServerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhxServerWeb do
    pipe_through :browser

    get "/", PageController, :index

  end

  scope "/api", PhxServerWeb do
    pipe_through :api

    post "/rpc", API.JsonRpcController, :cmd
  end
end
