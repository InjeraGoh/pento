defmodule PentoWeb.ToggleLive.Panel do
  use PentoWeb, :live_component

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:expanded, fn -> false end)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="rounded border p-4">
      <.button phx-click="toggle" phx-target={@myself}>
        <%= if @expanded, do: "Contract", else: "Expand" %>
      </.button>

      <%= if @expanded do %>
        <div class="mt-4 rounded border p-3">
          This content is now visible.
        </div>
      <% end %>
    </div>
    """
  end

  @impl true
  def handle_event("toggle", _, socket) do
    {:noreply, assign(socket, :expanded, !socket.assigns.expanded)}
  end
end
