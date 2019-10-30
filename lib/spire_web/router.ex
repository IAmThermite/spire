defmodule SpireWeb.Router do
  use SpireWeb, :router

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

  scope "/", SpireWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/leagues", LeagueController
    resources "/players", PlayerController
  end

  # Other scopes may use custom stacks.
  # scope "/api", SpireWeb do
  #   pipe_through :api
  # end
end
