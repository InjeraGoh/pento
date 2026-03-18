defmodule Pento.Survey do
  @moduledoc """
  The Survey context.
  """

  import Ecto.Query, warn: false
  alias Pento.Repo
  alias Pento.Survey.Demographic
  alias Pento.Survey.Demographic.Query, as: DemographicQuery
  alias Pento.Accounts.Scope
  alias Pento.Survey.Rating


  @doc """
  Subscribes to scoped notifications about any demographic changes.

  The broadcasted messages match the pattern:

    * {:created, %Demographic{}}
    * {:updated, %Demographic{}}
    * {:deleted, %Demographic{}}

  """
  def subscribe_demographics(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Pento.PubSub, "user:#{key}:demographics")
  end

  defp broadcast_demographic(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Pento.PubSub, "user:#{key}:demographics", message)
  end

  @doc """
  Returns the list of demographics.

  ## Examples

      iex> list_demographics(scope)
      [%Demographic{}, ...]

  """
  def list_demographics(%Scope{} = scope) do
    Repo.all_by(Demographic, user_id: scope.user.id)
  end

  @doc """
  Gets a demographic for the given user scope.
  Returns nil if no demographic exists for the user.
  """
  def get_demographic_by_user(%Scope{} = scope) do
    DemographicQuery.base()
    |> DemographicQuery.for_user(scope)
    |> Repo.one()
  end

  @doc """
  Gets a single demographic.

  Raises `Ecto.NoResultsError` if the Demographic does not exist.

  ## Examples

      iex> get_demographic!(scope, 123)
      %Demographic{}

      iex> get_demographic!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_demographic!(%Scope{} = scope, id) do
    Repo.get_by!(Demographic, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a demographic.

  ## Examples

      iex> create_demographic(scope, %{field: value})
      {:ok, %Demographic{}}

      iex> create_demographic(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_demographic(%Scope{} = scope, attrs) do
    with {:ok, demographic = %Demographic{}} <-
           %Demographic{}
           |> Demographic.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_demographic(scope, {:created, demographic})
      {:ok, demographic}
    end
  end

  @doc """
  Updates a demographic.

  ## Examples

      iex> update_demographic(scope, demographic, %{field: new_value})
      {:ok, %Demographic{}}

      iex> update_demographic(scope, demographic, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_demographic(%Scope{} = scope, %Demographic{} = demographic, attrs) do
    true = demographic.user_id == scope.user.id

    with {:ok, demographic = %Demographic{}} <-
           demographic
           |> Demographic.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_demographic(scope, {:updated, demographic})
      {:ok, demographic}
    end
  end

  @doc """
  Deletes a demographic.

  ## Examples

      iex> delete_demographic(scope, demographic)
      {:ok, %Demographic{}}

      iex> delete_demographic(scope, demographic)
      {:error, %Ecto.Changeset{}}

  """
  def delete_demographic(%Scope{} = scope, %Demographic{} = demographic) do
    true = demographic.user_id == scope.user.id

    with {:ok, demographic = %Demographic{}} <-
           Repo.delete(demographic) do
      broadcast_demographic(scope, {:deleted, demographic})
      {:ok, demographic}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking demographic changes.

  ## Examples

      iex> change_demographic(scope, demographic)
      %Ecto.Changeset{data: %Demographic{}}

  """
  def change_demographic(%Scope{} = scope, %Demographic{} = demographic, attrs \\ %{}) do
    true = demographic.user_id == scope.user.id

    Demographic.changeset(demographic, attrs, scope)
  end



  @doc """
  Subscribes to scoped notifications about any rating changes.

  The broadcasted messages match the pattern:

    * {:created, %Rating{}}
    * {:updated, %Rating{}}
    * {:deleted, %Rating{}}

  """
  def subscribe_ratings(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Pento.PubSub, "user:#{key}:ratings")
  end

  defp broadcast_rating(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Pento.PubSub, "user:#{key}:ratings", message)
  end

  @doc """
  Returns the list of ratings.

  ## Examples

      iex> list_ratings(scope)
      [%Rating{}, ...]

  """
  def list_ratings(%Scope{} = scope) do
    Repo.all_by(Rating, user_id: scope.user.id)
  end

  @doc """
  Gets a single rating.

  Raises `Ecto.NoResultsError` if the Rating does not exist.

  ## Examples

      iex> get_rating!(scope, 123)
      %Rating{}

      iex> get_rating!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_rating!(%Scope{} = scope, id) do
    Repo.get_by!(Rating, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a rating.

  ## Examples

      iex> create_rating(scope, %{field: value})
      {:ok, %Rating{}}

      iex> create_rating(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rating(%Scope{} = scope, attrs) do
    with {:ok, rating = %Rating{}} <-
           %Rating{}
           |> Rating.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_rating(scope, {:created, rating})
      {:ok, rating}
    end
  end

  @doc """
  Updates a rating.

  ## Examples

      iex> update_rating(scope, rating, %{field: new_value})
      {:ok, %Rating{}}

      iex> update_rating(scope, rating, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rating(%Scope{} = scope, %Rating{} = rating, attrs) do
    true = rating.user_id == scope.user.id

    with {:ok, rating = %Rating{}} <-
           rating
           |> Rating.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_rating(scope, {:updated, rating})
      {:ok, rating}
    end
  end

  @doc """
  Deletes a rating.

  ## Examples

      iex> delete_rating(scope, rating)
      {:ok, %Rating{}}

      iex> delete_rating(scope, rating)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rating(%Scope{} = scope, %Rating{} = rating) do
    true = rating.user_id == scope.user.id

    with {:ok, rating = %Rating{}} <-
           Repo.delete(rating) do
      broadcast_rating(scope, {:deleted, rating})
      {:ok, rating}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rating changes.

  ## Examples

      iex> change_rating(scope, rating)
      %Ecto.Changeset{data: %Rating{}}

  """
  def change_rating(%Scope{} = scope, %Rating{} = rating, attrs \\ %{}) do
    true = rating.user_id == scope.user.id

    Rating.changeset(rating, attrs, scope)
  end
end
