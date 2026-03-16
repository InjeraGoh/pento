defmodule PentoWeb.QuestionLive.Form do
  use PentoWeb, :live_view

  alias Pento.FAQ
  alias Pento.FAQ.Question

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage question records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="question-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:question]} type="text" label="Question" />
        <.input field={@form[:answer]} type="textarea" label="Answer" />
        <.input field={@form[:votes]} type="number" label="Votes" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Question</.button>
          <.button navigate={return_path(@current_scope, @return_to, @question)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    question = FAQ.get_question!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Question")
    |> assign(:question, question)
    |> assign(:form, to_form(FAQ.change_question(socket.assigns.current_scope, question)))
  end

  defp apply_action(socket, :new, _params) do
    question = %Question{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Question")
    |> assign(:question, question)
    |> assign(:form, to_form(FAQ.change_question(socket.assigns.current_scope, question)))
  end

  @impl true
  def handle_event("validate", %{"question" => question_params}, socket) do
    changeset = FAQ.change_question(socket.assigns.current_scope, socket.assigns.question, question_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"question" => question_params}, socket) do
    save_question(socket, socket.assigns.live_action, question_params)
  end

  defp save_question(socket, :edit, question_params) do
    case FAQ.update_question(socket.assigns.current_scope, socket.assigns.question, question_params) do
      {:ok, question} ->
        {:noreply,
         socket
         |> put_flash(:info, "Question updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, question)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_question(socket, :new, question_params) do
    case FAQ.create_question(socket.assigns.current_scope, question_params) do
      {:ok, question} ->
        {:noreply,
         socket
         |> put_flash(:info, "Question created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, question)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _question), do: ~p"/questions"
  defp return_path(_scope, "show", question), do: ~p"/questions/#{question}"
end
