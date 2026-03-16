defmodule PentoWeb.QuestionLive.Show do
  use PentoWeb, :live_view

  alias Pento.FAQ

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Question {@question.id}
        <:subtitle>This is a question record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/questions"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/questions/#{@question}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit question
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Question">{@question.question}</:item>
        <:item title="Answer">{@question.answer}</:item>
        <:item title="Votes">{@question.votes}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      FAQ.subscribe_questions(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Question")
     |> assign(:question, FAQ.get_question!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Pento.FAQ.Question{id: id} = question},
        %{assigns: %{question: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :question, question)}
  end

  def handle_info(
        {:deleted, %Pento.FAQ.Question{id: id}},
        %{assigns: %{question: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current question was deleted.")
     |> push_navigate(to: ~p"/questions")}
  end

  def handle_info({type, %Pento.FAQ.Question{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
