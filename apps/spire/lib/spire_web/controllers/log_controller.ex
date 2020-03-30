defmodule Spire.SpireWeb.LogController do
  use Spire.SpireWeb, :controller
  require Logger

  alias Spire.SpireDB.Logs
  alias Spire.SpireDB.Logs.Log
  alias Spire.SpireDB.Logs.Uploads
  alias Spire.SpireWeb.LogHelper

  plug Spire.SpireWeb.Plugs.RequireAuthentication
  plug :require_permissions when action in [:delete, :update, :edit, :process]

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
    log_id =
      logfile
      |> String.split("/")
      |> List.last()
      |> String.split("#")
      |> List.first()

    response = HTTPoison.get("https://logs.tf/json/#{log_id}")

    case response do
      {:ok, %{body: body}} ->
        %{
          "teams" => %{"Red" => red_team, "Blue" => blue_team},
          "players" => players,
          "info" => log_info,
          "length" => length
        } = log_json = Jason.decode!(body)

        num_of_players = map_size(players)

        # 6v6 (could have subs etc pop in and out however), i think spec is actually >= 12 < 18
        if num_of_players >= 12 and num_of_players <= 15 do
          log_data = %{
            logfile: log_id,
            map: log_info["map"],
            red_score: red_team["score"],
            blue_score: blue_team["score"],
            red_kills: red_team["kills"],
            blue_kills: blue_team["kills"],
            red_damage: red_team["dmg"],
            blue_damage: blue_team["dmg"],
            length: length,
            date: DateTime.from_unix!(log_info["date"]),
            match_id: log_params["match_id"]
          }

          if LogHelper.can_upload?(log_json, conn) do
            case handle_valid_log(log_data) do
              {:ok, log} ->
                status =
                  case log_params["match_id"] do
                    nil ->
                      "PENDING"
                    _id ->
                      "WAITING"
                  end
                with {:ok, upload} <- Uploads.create_upload(%{uploaded_by: conn.assigns.user.id, status: status, log_id: log.id}),
                     queue <- send_to_queue(conn, upload, log) do
                case queue do
                  {:ok, nil} ->
                    conn
                    |> put_flash(:info, "Log sucessfully uploaded. Please wait for an admin to approve.")
                    |> redirect(to: Routes.page_path(conn, :index))

                  {:ok, %Uploads.Upload{}} ->
                    conn
                    |> put_flash(:info, "Log sucessfully uploaded. Processing will be completed shortly.")
                    |> redirect(to: Routes.page_path(conn, :index))

                  {:error, %Ecto.Changeset{}} ->
                    conn
                    |> put_flash(:error, "Something went wrong uploading, contact an admin for more")
                    |> redirect(to: Routes.page_path(conn, :index))

                  {:error, _error} ->
                    conn
                    |> put_flash(:error, "Log was created but could not be processed, contact an admin for more.")
                    |> redirect(to: Routes.page_path(conn, :index))

                end

              else
                {:error, %Ecto.Changeset{} = changeset} ->
                  Logger.error("Failed to update upload, upload potentially in bad state", changeset: changeset)
                  conn
                  |> put_flash(:error, "Failed to update upload, upload potentially in bad state.")
                  |> redirect(to: Routes.admin_path(conn, :index))

                {:error, message} ->
                  conn
                  |> put_flash(:error, message)
                  |> redirect(to: Routes.admin_path(conn, :index))
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

      {:error, error} ->
        Logger.error("Error occured fetching log info", error: error)
        conn
        |> put_flash(:error, "Failed to get log info")
        |> redirect(to: Routes.log_path(conn, :new))
    end
  end

  defp handle_valid_log(log_data) do
    case Logs.create_log(log_data) do
      {:ok, log} ->
        {:ok, log}

      {:error, changeset} ->
        {:error, changeset}
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

  def process(conn, %{"id" => id}) do
    upload = Uploads.get_upload!(id)
    log = upload.log
    case handle_upload(upload, log) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Log approved and sent to queue.")
        |> redirect(to: Routes.admin_path(conn, :index))

      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:error, "Upload could not be updated, check the logs.")
        |> redirect(to: Routes.admin_path(conn, :index))

      {:error, error} ->
        conn
        |> put_flash(:error, error)
        |> redirect(to: Routes.admin_path(conn, :index))
    end
  end

  defp send_to_queue(conn, upload, log) do
    cond do
      Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :is_super_admin) ->
        handle_upload(upload, log)

      Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :can_manage_logs) ->
        handle_upload(upload, log)

      true ->
        if log.match_id do
          {:ok, nil}
        else
          handle_upload(upload, log)
        end
    end
  end

  defp handle_upload(upload, log) do
    case LogHelper.handle_upload(upload, log) do
      {:ok, _} ->
        Uploads.update_upload(upload, %{status: "PENDING"})

      {:error, error} ->
        Logger.error("Could not send log to queue", error: error)
        {:error, "Failed to send upload to queue. Try again later"}
    end
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
