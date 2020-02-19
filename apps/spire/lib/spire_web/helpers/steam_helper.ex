defmodule SpireWeb.SteamHelper do  
  # https://developer.valvesoftware.com/wiki/SteamID
  # https://github.com/ericentin/steamex/blob/master/lib/steamex/steam_id.ex#L14
  def community_id_to_steam_id(community_id) do
    steam_id1 = rem(community_id, 2)
    steam_id2 = community_id - 76_561_197_960_265_728

    steam_id2 = div(steam_id2 - steam_id1, 2)

    "STEAM_0:#{steam_id1}:#{steam_id2}" # 0 since tf2 is old
  end

  # https://github.com/ericentin/steamex/blob/master/lib/steamex/steam_id.ex#L37
  def community_id_to_steam_id3(community_id) do
    steam_id2 = community_id - 76_561_197_960_265_728

    "[U:1:#{steam_id2}]"
  end

  def get_steamid_type(steamid) do
    cond do
      String.starts_with?(steamid, "STEAM_") ->
        :steamid

      String.starts_with?(steamid, "[U:") ->
        :steamid3

      String.starts_with?("7") ->
        :steamid64

      true ->
        :invalid
    end
  end
end