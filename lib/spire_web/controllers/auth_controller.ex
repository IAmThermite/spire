defmodule SpireWeb.AuthController do
  use SpireWeb, :controller

  plug(Ueberauth)

  alias Ueberauth.Strategy.Helpers
  alias Spire.Players

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Players.get_or_create_from_auth(auth) do
      {:ok, player} ->
        conn
        |> put_flash(:info, "Logged in.")
        |> put_session(:user_id, player.id)
        |> redirect(to: "/")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Failed to log in")
        |> redirect(to: "/")
    end
  end
end
