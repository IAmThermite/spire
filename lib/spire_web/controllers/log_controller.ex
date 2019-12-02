defmodule SpireWeb.LogController do
  use SpireWeb, :controller

  alias Spire.Logs
  alias Spire.Logs.Log
  alias Spire.Leagues.Matches

  def index(conn, %{"player_id" => player_id}) do
    player_id = String.to_integer(player_id)
    logs = Logs.list_logs_by_player(player_id)
    render(conn, "index.html", logs: logs)
  end

  def new(conn, _params) do
    changeset = Logs.change_log(%Log{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"log" => log_params}) do
    case Logs.create_log(log_params) do
      {:ok, log} ->
        conn
        |> put_flash(:info, "Log created successfully.")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    log = Logs.get_log!(id)
    render(conn, "show.html", log: log)
  end

  def edit(conn, %{"id" => id}) do
    log = Logs.get_log!(id)
    changeset = Logs.change_log(log)
    render(conn, "edit.html", log: log, changeset: changeset)
  end

  def update(conn, %{"id" => id, "log" => log_params}) do
    log = Logs.get_log!(id)

    case Logs.update_log(log, log_params) do
      {:ok, log} ->
        conn
        |> put_flash(:info, "Log updated successfully.")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", log: log, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    log = Logs.get_log!(id)
    {:ok, _log} = Logs.delete_log(log)

    conn
    |> put_flash(:info, "Log deleted successfully.")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
