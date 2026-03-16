defmodule Pento.FAQ do
  @moduledoc """
  The FAQ context.
  """

  import Ecto.Query, warn: false
  alias Pento.Repo

  alias Pento.FAQ.Question
  alias Pento.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any question changes.

  The broadcasted messages match the pattern:

    * {:created, %Question{}}
    * {:updated, %Question{}}
    * {:deleted, %Question{}}

  """
  def subscribe_questions(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Pento.PubSub, "user:#{key}:questions")
  end

  defp broadcast_question(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Pento.PubSub, "user:#{key}:questions", message)
  end

  @doc """
  Returns the list of questions.

  ## Examples

      iex> list_questions(scope)
      [%Question{}, ...]

  """
  def list_questions(%Scope{} = scope) do
    Repo.all_by(Question, user_id: scope.user.id)
  end

  @doc """
  Gets a single question.

  Raises `Ecto.NoResultsError` if the Question does not exist.

  ## Examples

      iex> get_question!(scope, 123)
      %Question{}

      iex> get_question!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_question!(%Scope{} = scope, id) do
    Repo.get_by!(Question, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a question.

  ## Examples

      iex> create_question(scope, %{field: value})
      {:ok, %Question{}}

      iex> create_question(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_question(%Scope{} = scope, attrs) do
    with {:ok, question = %Question{}} <-
           %Question{}
           |> Question.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_question(scope, {:created, question})
      {:ok, question}
    end
  end

  @doc """
  Updates a question.

  ## Examples

      iex> update_question(scope, question, %{field: new_value})
      {:ok, %Question{}}

      iex> update_question(scope, question, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_question(%Scope{} = scope, %Question{} = question, attrs) do
    true = question.user_id == scope.user.id

    with {:ok, question = %Question{}} <-
           question
           |> Question.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_question(scope, {:updated, question})
      {:ok, question}
    end
  end

  @doc """
  Deletes a question.

  ## Examples

      iex> delete_question(scope, question)
      {:ok, %Question{}}

      iex> delete_question(scope, question)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question(%Scope{} = scope, %Question{} = question) do
    true = question.user_id == scope.user.id

    with {:ok, question = %Question{}} <-
           Repo.delete(question) do
      broadcast_question(scope, {:deleted, question})
      {:ok, question}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question changes.

  ## Examples

      iex> change_question(scope, question)
      %Ecto.Changeset{data: %Question{}}

  """
  def change_question(%Scope{} = scope, %Question{} = question, attrs \\ %{}) do
    true = question.user_id == scope.user.id

    Question.changeset(question, attrs, scope)
  end
end
