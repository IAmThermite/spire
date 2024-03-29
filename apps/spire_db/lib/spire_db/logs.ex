defmodule Spire.SpireDB.Logs do
  @moduledoc """
  The Logs context.
  """

  import Ecto.Query, warn: false
  alias Spire.SpireDB.Repo

  alias Spire.SpireDB.Logs.Log
  alias Spire.SpireDB.Players.PlayersLogs

  @doc """
  Returns the list of logs.

  ## Examples

      iex> list_logs_by_player(123)
      [%Log{}, ...]

  """
  def list_logs_by_player(player_id) do
    Repo.all(
      from(l in PlayersLogs, where: l.player_id == ^player_id, order_by: [desc: l.inserted_at])
    )
    |> Repo.preload([:log])
    |> Enum.map(fn l ->
      l.log
    end)
  end

  @doc """
  Gets a single log.

  Raises `Ecto.NoResultsError` if the Log does not exist.

  ## Examples

      iex> get_log!(123)
      %Log{}

      iex> get_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_log!(id), do: Repo.get!(Log, id)

  @doc """
  Creates a log.

  ## Examples

      iex> create_log(%{field: value})
      {:ok, %Log{}}

      iex> create_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_log(attrs \\ %{}) do
    %Log{}
    |> Log.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a log.

  ## Examples

      iex> update_log(log, %{field: new_value})
      {:ok, %Log{}}

      iex> update_log(log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_log(%Log{} = log, attrs) do
    log
    |> Log.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Log.

  ## Examples

      iex> delete_log(log)
      {:ok, %Log{}}

      iex> delete_log(log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_log(%Log{} = log) do
    Repo.delete(log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking log changes.

  ## Examples

      iex> change_log(log)
      %Ecto.Changeset{source: %Log{}}

  """
  def change_log(%Log{} = log) do
    Log.changeset(log, %{})
  end
end
