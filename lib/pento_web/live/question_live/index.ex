defmodule PentoWeb.QuestionLive.Index do
  use PentoWeb, :live_view

  alias Pento.FAQ

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Questions
        <:actions>
          <.button variant="primary" navigate={~p"/questions/new"}>
            <.icon name="hero-plus" /> New Question
          </.button>
        </:actions>
      </.header>

      <.table
        id="questions"
        rows={@streams.questions}
        row_click={fn {_id, question} -> JS.navigate(~p"/questions/#{question}") end}
      >
        <:col :let={{_id, question}} label="Question">{question.question}</:col>
        <:col :let={{_id, question}} label="Answer">{question.answer}</:col>
        <:col :let={{_id, question}} label="Votes">{question.votes}</:col>
        <:action :let={{_id, question}}>
          <div class="sr-only">
            <.link navigate={~p"/questions/#{question}"}>Show</.link>
          </div>
          <.link navigate={~p"/questions/#{question}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, question}}>
          <.link
            phx-click={JS.push("delete", value: %{id: question.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      FAQ.subscribe_questions(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Questions")
     |> stream(:questions, list_questions(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    question = FAQ.get_question!(socket.assigns.current_scope, id)
    {:ok, _} = FAQ.delete_question(socket.assigns.current_scope, question)

    {:noreply, stream_delete(socket, :questions, question)}
  end

  @impl true
  def handle_info({type, %Pento.FAQ.Question{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :questions, list_questions(socket.assigns.current_scope), reset: true)}
  end

  defp list_questions(current_scope) do
    FAQ.list_questions(current_scope)
  end
end
