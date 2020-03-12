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
  def add_stat(%{changes: stats} = changeset, stat, value) do
    new_stat = stats[stat] + value
    Ecto.Changeset.put_change(changeset, stat, new_stat)
  end

  @doc """
  Set an averaged value to the stats, i.e dpm
  """
  def average_stat(%{changes: stats} = changeset, stat, value) do
    if stats[stat] == 0 do
      Ecto.Changeset.put_change(changeset, stat, value)
    else
      new_stat = (stats[stat] + (stats[stat] + value)) / 2
      Ecto.Changeset.put_change(changeset, stat, new_stat)
    end
  end
end
