defmodule Spire.UploadCompiler.CalculationUtils do
  @primary_weapons [
    "scattergun",
    "tf_projectile_rocket",
    "quake_rl",
    "rocketlauncher_directhit",
    # ?
    "air_strike",
    # ?
    "liberty_launcher",
    "blackbox",
    "flamethrower",
    "degreaser",
    # ?
    "backburner",
    # ?
    "phlogistinator",
    "tf_projectile_pipe",
    "iron_bomber",
    # ?
    "loch_n_load",
    "minigun",
    "long_heatmaker",
    "tomislav",
    "brass_beast",
    "shotgun_primary",
    "frontier_justice",
    "widowmaker",
    "crusaders_crossbow",
    "sniperrifle",
    "awper_hand",
    "revolver",
    "ambassador",
    "letranger",
    "enforcer"
  ]

  @secondary_weapons [
    "scout_pistol",
    "max_gun",
    "shotgun_soldier",
    "flaregun",
    "shotgun_pyro",
    "tf_projectile_pipe_remote",
    "quickiebomb_launcher",
    "shotgun_heavy",
    # ?
    "family_buisness",
    "pistol",
    "smg"
  ]

  def primary_weapons(), do: @primary_weapons
  def secondary_weapons(), do: @secondary_weapons

  @doc """
  Add the value to the stats, i.e kills
  """
  def add_stat(stats, stat, value) when is_number(value) do
    new_stat = Map.get(stats, stat) + value
    %{stats | stat => new_stat}
  end

  @doc """
  Set an averaged value to the stats, i.e dpm
  """
  def average_stat(stats, stat, value) when is_number(value) do
    if Map.get(stats, stat) == 0 do
      %{stats | stat => value}
    else
      new_stat = (Map.get(stats, stat) + value) / 2
      %{stats | stat => new_stat}
    end
  end

  @doc """
  Set a value on the stats
  """
  def put_stat(stats, stat, value) when is_number(value) do
    %{stats | stat => value}
  end
end
