defmodule Spire.Utils.SteamUtils do
  @moduledoc """
  Utility functions to make steam based operations
  easier
  """

  @steam_api_key Application.get_env(:utils, :steam_api_key)

  # https://developer.valvesoftware.com/wiki/SteamID
  # https://github.com/ericentin/steamex/blob/master/lib/steamex/steam_id.ex#L14
  @doc """
  Convert a steamid 64 to a steamid

  ## Examples

      iex> Spire.Utils.SteamUtils.community_id_to_steam_id("76561198118389766")
      "STEAM_0:0:79062019"
  """
  def community_id_to_steam_id(community_id) do
    steamid64 = String.to_integer(community_id)
    steam_id1 = rem(steamid64, 2)
    steam_id2 = steamid64 - 76_561_197_960_265_728

    steam_id2 = div(steam_id2 - steam_id1, 2)

    # 0 since tf2 is old
    "STEAM_0:#{steam_id1}:#{steam_id2}"
  end

  # https://github.com/ericentin/steamex/blob/master/lib/steamex/steam_id.ex#L37
  @doc """
  Convert a steamid 64 to a steamid 3

  ## Examples

      iex> Spire.Utils.SteamUtils.community_id_to_steam_id3("76561198118389766")
      "[U:1:158124038]"
  """
  def community_id_to_steam_id3(community_id) do
    steamid64 = String.to_integer(community_id)
    steam_id2 = steamid64 - 76_561_197_960_265_728

    "[U:1:#{steam_id2}]"
  end

  @doc """
  Returns the steamid type as an atom

  ## Examples

      iex> Spire.Utils.SteamUtils.get_steamid_type("STEAM_0:0:79062019")
      :steamid

      iex> Spire.Utils.SteamUtils.get_steamid_type("[U:1:158124038]")
      :steamid3

      iex> Spire.Utils.SteamUtils.get_steamid_type("76561198118389766")
      :steamid64

      iex> Spire.Utils.SteamUtils.get_steamid_type("NOT A VALID STEAM ID")
      :invalid
  """
  def get_steamid_type(steamid) do
    cond do
      String.starts_with?(steamid, "STEAM_") ->
        :steamid

      String.starts_with?(steamid, "[U:") ->
        :steamid3

      String.starts_with?(steamid, "7") ->
        :steamid64

      true ->
        :invalid
    end
  end

  @doc """
  Converts steamid to steamid64

  ## Examples

      iex> Spire.Utils.SteamUtils.steamid_to_steamid64("STEAM_0:0:79062019")
      "76561198118389766"

      iex> Spire.Utils.SteamUtils.steamid_to_steamid64("[U:1:158124038]")
      "76561198118389766"
  """
  def steamid_to_steamid64(steamid) do
    if String.starts_with?(steamid, "[") do
      parts =
        String.replace(steamid, "[U:", "")
        |> String.replace("]", "")
        |> String.split(":")

      [part1, part2] =
        Enum.map(parts, fn part ->
          {num, _} = Integer.parse(part)
          num
        end)

      (part1 + part2 + 76_561_197_960_265_727)
      |> Integer.to_string()
    else
      parts =
        String.replace(steamid, "STEAM_0:", "")
        |> String.split(":")

      [part1, part2] =
        Enum.map(parts, fn part ->
          {num, _} = Integer.parse(part)
          num
        end)

      (part1 + part2 * 2 + 76_561_197_960_265_728)
      |> Integer.to_string()
    end
  end

  def get_steam_player(steamid64) do
    res =
      HTTPoison.get!(
        "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=#{@steam_api_key}&steamids=#{
          steamid64
        }"
      )

    %{"response" => %{"players" => players}} = Jason.decode!(res.body)

    case players do
      [player | _tail] ->
        {:ok, player}

      _ ->
        {:error, nil}
    end
  end

  def get_steamids("[U:" <> _remainder = steamid) do
    steamid64 = steamid_to_steamid64(steamid)

    %{
      steamid: community_id_to_steam_id(steamid64),
      steamid3: steamid,
      steamid64: steamid64
    }
  end

  def get_steamids("STEAM_" <> _remainder = steamid) do
    steamid64 = steamid_to_steamid64(steamid)

    %{
      steamid: steamid,
      steamid3: community_id_to_steam_id3(steamid64),
      steamid64: steamid64
    }
  end
end
