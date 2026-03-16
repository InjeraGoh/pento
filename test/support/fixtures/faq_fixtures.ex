defmodule Pento.FAQFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pento.FAQ` context.
  """

  @doc """
  Generate a question.
  """
  def question_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        answer: "some answer",
        question: "some question",
        votes: 42
      })

    {:ok, question} = Pento.FAQ.create_question(scope, attrs)
    question
  end
end
