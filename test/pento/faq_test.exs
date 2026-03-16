defmodule Pento.FAQTest do
  use Pento.DataCase

  alias Pento.FAQ

  describe "questions" do
    alias Pento.FAQ.Question

    import Pento.AccountsFixtures, only: [user_scope_fixture: 0]
    import Pento.FAQFixtures

    @invalid_attrs %{question: nil, answer: nil, votes: nil}

    test "list_questions/1 returns all scoped questions" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      question = question_fixture(scope)
      other_question = question_fixture(other_scope)
      assert FAQ.list_questions(scope) == [question]
      assert FAQ.list_questions(other_scope) == [other_question]
    end

    test "get_question!/2 returns the question with given id" do
      scope = user_scope_fixture()
      question = question_fixture(scope)
      other_scope = user_scope_fixture()
      assert FAQ.get_question!(scope, question.id) == question
      assert_raise Ecto.NoResultsError, fn -> FAQ.get_question!(other_scope, question.id) end
    end

    test "create_question/2 with valid data creates a question" do
      valid_attrs = %{question: "some question", answer: "some answer", votes: 42}
      scope = user_scope_fixture()

      assert {:ok, %Question{} = question} = FAQ.create_question(scope, valid_attrs)
      assert question.question == "some question"
      assert question.answer == "some answer"
      assert question.votes == 42
      assert question.user_id == scope.user.id
    end

    test "create_question/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = FAQ.create_question(scope, @invalid_attrs)
    end

    test "update_question/3 with valid data updates the question" do
      scope = user_scope_fixture()
      question = question_fixture(scope)
      update_attrs = %{question: "some updated question", answer: "some updated answer", votes: 43}

      assert {:ok, %Question{} = question} = FAQ.update_question(scope, question, update_attrs)
      assert question.question == "some updated question"
      assert question.answer == "some updated answer"
      assert question.votes == 43
    end

    test "update_question/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      question = question_fixture(scope)

      assert_raise MatchError, fn ->
        FAQ.update_question(other_scope, question, %{})
      end
    end

    test "update_question/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      question = question_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = FAQ.update_question(scope, question, @invalid_attrs)
      assert question == FAQ.get_question!(scope, question.id)
    end

    test "delete_question/2 deletes the question" do
      scope = user_scope_fixture()
      question = question_fixture(scope)
      assert {:ok, %Question{}} = FAQ.delete_question(scope, question)
      assert_raise Ecto.NoResultsError, fn -> FAQ.get_question!(scope, question.id) end
    end

    test "delete_question/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      question = question_fixture(scope)
      assert_raise MatchError, fn -> FAQ.delete_question(other_scope, question) end
    end

    test "change_question/2 returns a question changeset" do
      scope = user_scope_fixture()
      question = question_fixture(scope)
      assert %Ecto.Changeset{} = FAQ.change_question(scope, question)
    end
  end
end
