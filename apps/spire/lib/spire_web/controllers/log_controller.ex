defmodule Spire.SpireWeb.LogController do
  use Spire.SpireWeb, :controller

  alias Spire.SpireDB.Logs
  alias Spire.SpireDB.Logs.Log
  alias Spire.SpireDB.Logs.Uploads
  alias Spire.SpireWeb.LogHelper

  plug Spire.SpireWeb.Plugs.RequireAuthentication when action not in [:index, :show]
  plug :require_permissions when action in [:delete, :update, :edit, :new]

  def index(conn, %{"player_id" => player_id}) do
    player_id = String.to_integer(player_id)
    logs = Logs.list_logs_by_player(player_id)
    render(conn, "index.html", logs: logs)
  end

  def new(conn, _params) do
    changeset = Logs.change_log(%Log{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"log" => %{"logfile" => logfile} = log_params} = _params) do
    response = HTTPoison.get!("https://logs.tf/json/#{logfile}")

    case response do
      %{body: body} ->
        %{
          "teams" => %{"Red" => red_team, "Blue" => blue_team},
          "players" => players,
          "info" => log_info
        } = log_json = Jason.decode!(body)

        num_of_players = map_size(players)

        # 6v6 (could have subs etc pop in and out however), i think spec is actually >= 12 < 18
        if num_of_players >= 12 and num_of_players <= 15 do
          log_data = %{
            logfile: logfile,
            map: log_info["map"],
            red_score: red_team["score"],
            blue_score: blue_team["score"],
            red_kills: red_team["kills"],
            blue_kills: blue_team["kills"],
            red_damage: red_team["dmg"],
            blue_damage: blue_team["dmg"],
            length: log_info["total_length"],
            date: DateTime.from_unix!(log_info["date"]),
            match_id: log_params["match_id"]
          }

          if LogHelper.can_upload?(log_json, conn) do
            case Logs.create_log(log_data) do
              {:ok, log} ->
                case Uploads.create_upload(%{uploaded_by: conn.assigns[:user].id, log_id: log.id}) do
                  {:ok, upload} ->
                    res = LogHelper.handle_upload(log, upload)

                    case res do
                      {:ok, _response} ->
                        conn
                        |> put_flash(
                          :info,
                          "Log created successfully. Processing will be completed shortly"
                        )
                        |> redirect(to: Routes.page_path(conn, :index))

                      {:error, _error} ->
                        conn
                        |> put_flash(
                          :error,
                          "Error attempting to process log, contact admin for more"
                        )
                        |> redirect(to: Routes.page_path(conn, :index))
                    end

                  err ->
                    Logger.error("#{__MODULE__}.create: #{inspect(err)}")

                    conn
                    |> put_flash(
                      :error,
                      "Log was uploaded but something went wrong, contact an admin for more"
                    )
                    |> redirect(to: Routes.log_path(conn, :new))
                end

              {:error, %Ecto.Changeset{} = changeset} ->
                render(conn, "new.html", changeset: changeset)
            end
          else
            conn
            |> put_flash(
              :error,
              "Not allowed to upload that log. If you think this is a mistake contact an admin."
            )
            |> redirect(to: Routes.log_path(conn, :new))
          end
        else
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

  defp require_permissions(conn, _) do
    cond do
      Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :is_super_admin) ->
        conn

      Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :can_manage_logs) ->
        conn

      true ->
        conn
        |> put_flash(:error, "You do not have the permissions to do this")
        |> redirect(to: Routes.page_path(conn, :index))
        |> halt
    end
  end
end
