defmodule Spire.SpireWeb.Router do
  use Spire.SpireWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Spire.SpireWeb.Plugs.SetPlayer
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Spire.SpireWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/about", PageController, :about

    get "/admin", AdminController, :index

    resources "/leagues", LeagueController do
      resources "/matches", MatchController, only: [:new, :index, :create]
    end

    resources "/matches", MatchController, except: [:new, :index, :create]

    resources "/logs", LogController, except: [:index]

    get "/logs/:id/process", LogController, :process

    get "/players/compare", PlayerController, :compare

    resources "/players", PlayerController, except: [:new, :create] do
      resources "/logs", LogController, only: [:index]
    end
  end

  scope "/auth", Spire.SpireWeb do
    pipe_through :browser

    get "/logout", AuthController, :delete
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  scope "/api", Spire.SpireWeb do
    pipe_through :api

    get "/players/compare", Api.PlayerController, :compare
    resources "/players", Api.PlayerController, only: [:index, :show]
    resources "/matches", Api.MatchController, only: [:show]
  end
end
