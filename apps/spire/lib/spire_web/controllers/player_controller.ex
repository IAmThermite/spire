defmodule Spire.SpireWeb.PlayerController do
  use Spire.SpireWeb, :controller

  alias Spire.SpireDB.Players
  alias Spire.SpireDB.Players.Stats
  alias Spire.SpireDB.Leagues
  alias Spire.SpireDB.Players.Player
  alias Spire.SpireDB.Leagues.Matches
  alias Spire.SpireDB.Logs
  alias Spire.SpireDB.Players.Permissions

  plug Spire.SpireWeb.Plugs.RequireAuthentication when action not in [:index, :show, :compare]
  plug :require_permissions when action not in [:index, :show, :update, :edit, :compare]

  def index(conn, %{"search" => search}) do
    players = Players.list_players("%#{search}%")
    render(conn, "index.html", players: players)
  end

  def index(conn, _params) do
    players = Players.list_players()
    render(conn, "index.html", players: players)
  end

  def new(conn, _params) do
    changeset = Players.change_player(%Player{})
    league_options = Enum.map(Leagues.list_leagues(), fn l -> [value: l.id, key: l.name] end)
    render(conn, "new.html", league_options: league_options, changeset: changeset)
  end

  def create(conn, %{"player" => player_params}) do
    case Players.create_player(player_params) do
      {:ok, player} ->
        conn
        |> put_flash(:info, "Player created successfully.")
        |> redirect(to: Routes.player_path(conn, :show, player))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    player = Players.get_player!(id)
    matches = Matches.list_matches_by_player(player.id)
    logs = Logs.list_logs_by_player(player.id)
    render(conn, "show.html", player: player, matches: matches, logs: logs)
  end

  def compare(
        conn,
        %{"player_1_id" => player_1_id, "player_2_id" => player_2_id, "type" => type} = params
      ) do
    player_1 = Players.get_by_steamid64(player_1_id)
    player_2 = Players.get_by_steamid64(player_2_id)

    cond do
      player_1 == nil ->
        conn
        |> put_flash(:error, "Could not find player with id of #{player_1_id}")
        |> redirect(to: Routes.player_path(conn, :compare))

      player_2 == nil ->
        conn
        |> put_flash(:error, "Could not find player with id of #{player_2_id}")
        |> redirect(to: Routes.player_path(conn, :compare))

      true ->
        stats =
          case params do
            %{"class" => class} when class != "" ->
              player_1_stats = Stats.get_stats_individual(player_1.id, type, class)
              player_2_stats = Stats.get_stats_individual(player_2.id, type, class)
              fields = Stats.Individual.fields_for_class(class)
              deltas = Stats.get_deltas(player_1_stats, player_2_stats, fields)

              %{
                player_1_stats: Map.take(player_1_stats || %{}, fields),
                player_2_stats: Map.take(player_2_stats || %{}, fields),
                deltas: Map.take(deltas, fields),
                fields: fields
              }

            _ ->
              player_1_stats = Stats.get_stats_all(player_1.id, type)
              player_2_stats = Stats.get_stats_all(player_2.id, type)
              fields = Stats.get_stats_all_fields()
              deltas = Stats.get_deltas(player_1_stats, player_2_stats, fields)

              %{
                player_1_stats: player_1_stats,
                player_2_stats: player_2_stats,
                deltas: deltas,
                fields: fields
              }
          end

        render(conn, "compare.html", player_1: player_1, player_2: player_2, stats: stats)
    end
  end

  def compare(conn, _params) do
    players = Players.list_players()
    render(conn, "compare.html", players: players)
  end

  def edit(conn, %{"id" => id}) do
    if can_edit?(conn, id) do
      render_form(conn, id)
    else
      conn
      |> put_flash(:error, "You do not have the permissions to do this")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt
    end
  end

  def update(conn, %{"id" => id, "player" => player_params}) do
    if can_edit?(conn, id) do
      player = Players.get_player!(id)

      # only admins can change division
      modified_params =
        if can_manage?(conn) do
          Map.drop(player_params, [:division])
        else
          player_params
        end

      case Players.update_player(player, modified_params) do
        {:ok, player} ->
          conn
          |> put_flash(:info, "Player updated successfully.")
          |> redirect(to: Routes.player_path(conn, :show, player))

        {:error, %Ecto.Changeset{} = changeset} ->
          render_form_with_changeset(conn, id, changeset)
      end
    else
      conn
      |> put_flash(:error, "You do not have the permissions to do this")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt
    end
  end

  def update(conn, %{"id" => id, "permission" => permission_params}) do
    if can_manage?(conn) do
      player = Players.get_player!(id)

      modified_params =
        permission_params
        |> Map.put("player_id", id)

      case Permissions.create_or_update_permissions(modified_params) do
        {:ok, _permissions} ->
          conn
          |> put_flash(:info, "Player permissions updated successfully.")
          |> redirect(to: Routes.player_path(conn, :show, player))

        {:error, _changeset} ->
          conn
          |> put_flash(:error, "Something went wrong when updating permissions")
          |> render_form(id)
      end
    else
      conn
      |> put_flash(:error, "You do not have the permissions to do this")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt
    end
  end

  # defp search(conn, _params) do
  #   players = Players.list_players()
  #   conn
  #   |> redirect(to: Routes.player_path(conn, :index))
  # end

  defp require_permissions(conn, _) do
    if Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :can_manage_players) do
      conn
    else
      conn
      |> put_flash(:error, "You do not have the permissions to do this")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt
    end
  end

  defp can_edit?(conn, player_id) do
    {id, _} = Integer.parse(player_id)

    cond do
      id == conn.assigns[:user].id ->
        true

      true ->
        can_manage?(conn)
    end
  end

  defp can_manage?(conn) do
    cond do
      Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :is_super_admin) ->
        true

      Spire.SpireWeb.PermissionsHelper.has_permissions_for?(conn, :can_manage_players) ->
        true

      true ->
        false
    end
  end

  defp render_form(conn, player_id) do
    player = Players.get_player!(player_id)
    permissions = Permissions.get_permissions_for_player(player_id)
    league_options = Enum.map(Leagues.list_leagues(), fn l -> [value: l.id, key: l.name] end)
    changeset = Players.change_player(player)
    permissions_changeset = Permissions.change_permission(permissions)

    render(conn, "edit.html",
      player: player,
      permissions: permissions,
      league_options: league_options,
      changeset: changeset,
      permissions_changeset: permissions_changeset
    )
  end

  defp render_form_with_changeset(conn, player_id, changeset) do
    player = Players.get_player!(player_id)
    permissions = Permissions.get_permissions_for_player(player_id)
    league_options = Enum.map(Leagues.list_leagues(), fn l -> [value: l.id, key: l.name] end)
    permissions_changeset = Permissions.change_permission(permissions)

    render(conn, "edit.html",
      player: player,
      permissions: permissions,
      league_options: league_options,
      changeset: changeset,
      permissions_changeset: permissions_changeset
    )
  end
end
