defmodule SpireWeb.LogController do
  use SpireWeb, :controller

  alias Spire.Logs
  alias Spire.Logs.Log
  alias Spire.Logs.Uploads
  alias SpireWeb.LogHelper

  def index(conn, %{"player_id" => player_id}) do
    player_id = String.to_integer(player_id)
    logs = Logs.list_logs_by_player(player_id)
    render(conn, "index.html", logs: logs)
  end

  def new(conn, _params) do
    changeset = Logs.change_log(%Log{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"log" => %{"logfile" => logfile} = _log_params} = _params) do
    response = HTTPoison.get!("https://logs.tf/json/#{logfile}")

    case response do
      %{body: body} ->
        %{"teams" => %{"Red" => red_team, "Blue" => blue_team}, "players" => players, "info" => log_info} = log_json = Jason.decode!(body)
        num_of_players = map_size(players)
        
        cond do
          num_of_players >= 12 and num_of_players <= 15 -> # 6v6 (could have subs etc pop in and out however), i think spec is actually >= 12 < 18
            log_data = %{
              logfile: logfile,
              map: log_info["map"],
              red_score: red_team["score"],
              blue_score: blue_team["score"],
              red_kills: red_team["kills"],
              blue_kills: blue_team["score"],
              red_damage: red_team["dmg"],
              blue_damage: blue_team["dmg"],
              length: log_info["total_length"],
              date: DateTime.from_unix!(log_info["date"])
            }
            # need to check if log can be uploaded as well true <- LogHelper.can_upload?(log, conn)
            case Logs.create_log(log_data) do
              {:ok, log} ->
                with {:ok, _upload} <- Uploads.create_upload(%{uploaded_by: conn.assigns[:user].id, log_id: log.id}),
                     {:ok, extracted_players} <- LogHelper.extract_players_from_log(log_json),
                     true <- LogHelper.can_upload?(log, conn)
                do
                  # LogHelper.handle_upload(log, conn, extracted_players, match)
                  conn
                  |> put_flash(:info, "Log created successfully. Processing will be completed shortly")
                  |> redirect(to: Routes.page_path(conn, :index))
                else
                  err ->
                    Logger.error("LogControler.create: #{inspect(err)}")
                    conn
                    |> put_flash(:error, "Log was uploaded but something went wrong, contact an admin for more")
                    |> redirect(to: Routes.page_path(conn, :index))
                end
        
              {:error, %Ecto.Changeset{} = changeset} ->
                render(conn, "new.html", changeset: changeset)
            end
          true ->
            conn
            |> put_flash(:error, "Not a valid log (must be 6v6)")
            |> redirect(to: Routes.log_path(conn, :new))
        end
      _ ->
        conn
        |> put_flash(:error, "Failed to get log info")
        |> redirect(to: Routes.log_path(conn, :new))
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
      {:ok, _log} ->
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
