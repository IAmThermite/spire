defmodule Spire.SpireDB.Logs.Uploads do
  @moduledoc """
  The Logs.Uploads context.
  """

  import Ecto.Query, warn: false
  alias Spire.SpireDB.Repo

  alias Spire.SpireDB.Logs.Uploads.Upload

  @doc """
  Returns the list of upload.

  ## Examples

      iex> list_uploads()
      [%Upload{}, ...]

  """
  def list_uploads() do
    Repo.all(Upload)
    |> Repo.preload([:player, {:log, :match}])
  end

  @doc """
  Returns the list of uploads by uploader.

  ## Examples

      iex> list_uploads_by_player(123)
      [%Upload{}, ...]

  """
  def list_uploads_by_player(player_id) do
    Repo.all(from u in Upload, where: u.uploaded_by == ^player_id)
  end

  @doc """
  Gets a single upload.

  Raises `Ecto.NoResultsError` if the Upload does not exist.

  ## Examples

      iex> get_upload!(123)
      %Upload{}

      iex> get_upload!(456)
      ** (Ecto.NoResultsError)

  """
  def get_upload!(id) do
    Repo.get!(Upload, id)
    |> Repo.preload([:player, :log])
  end

  @doc """
  Creates a upload.

  ## Examples

      iex> create_upload(%{field: value})
      {:ok, %Upload{}}

      iex> create_upload(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_upload(attrs \\ %{}) do
    %Upload{}
    |> Upload.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a upload.

  ## Examples

      iex> update_upload(upload, %{field: new_value})
      {:ok, %Upload{}}

      iex> update_upload(upload, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_upload(%Upload{} = upload, attrs) do
    upload
    |> Upload.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Upload.

  ## Examples

      iex> delete_upload(upload)
      {:ok, %Upload{}}

      iex> delete_upload(upload)
      {:error, %Ecto.Changeset{}}

  """
  def delete_upload(%Upload{} = upload) do
    Repo.delete(upload)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking upload changes.

  ## Examples

      iex> change_upload(upload)
      %Ecto.Changeset{source: %Upload{}}

  """
  def change_upload(%Upload{} = upload) do
    Upload.changeset(upload, %{})
  end
end
