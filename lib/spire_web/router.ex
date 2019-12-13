defmodule SpireWeb.Router do
  use SpireWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SpireWeb.Plugs.SetPlayer
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SpireWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/about", PageController, :about

    resources "/leagues", LeagueController do
      resources "/matches", MatchController, only: [:new, :index, :create]
    end

    resources "/matches", MatchController, except: [:new, :index, :create]

    resources "/players", PlayerController

    resources "/logs", LogController
  end

  scope "/auth", SpireWeb do
    pipe_through :browser
  
    get "/logout", AuthController, :delete
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  scope "/api/v1", SpireWeb do
    pipe_through :api
  end
end
