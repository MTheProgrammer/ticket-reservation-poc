defmodule TipayWeb.Router do
  @moduledoc """
  Main App Router
  """
  @dialyzer {:nowarn_function, __checks__: 0}
  use TipayWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]

    plug Plug.Parsers,
      parsers: [:json, {:multipart, length: 5_000_000}],
      json_decoder: Jason

    plug Guardian.Plug.Pipeline,
      module: TipayWeb.Guardian,
      error_handler: TipayWeb.AuthErrorHandler

    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource, allow_blank: true
    plug TipayWeb.Plug.PutUserContext
  end

  # scope "/", TipayWeb do
  # pipe_through :browser

  # get "/", PageController, :index
  # end

  pipeline :tpay_callbacks do
    plug :accepts, ["json"]
  end

  scope "/tpay" do
    pipe_through :tpay_callbacks

    post "/transaction/notification", TipayWeb.Tpay.Notification, :notify, only: [:post]
  end

  scope "/api" do
    pipe_through :api

    post "/", Absinthe.Plug, schema: TipayWeb.Api.Schema
    get "/", Absinthe.Plug.GraphiQL, schema: TipayWeb.Api.Schema, interface: :playground
  end
end
