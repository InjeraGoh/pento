defmodule PentoWeb.SurveyLive do
  use PentoWeb, :live_view

  alias Pento.{Survey, Catalog}
  alias PentoWeb.DemographicLive.Show
  alias __MODULE__.Component

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_demographic()
      |> assign_products()

    {:ok, socket}
  end

  defp assign_demographic(socket) do
    demographic = Survey.get_demographic_by_user(socket.assigns.current_scope)
    assign(socket, :demographic, demographic)
  end

  defp assign_products(socket) do
    products = Catalog.list_products_with_user_rating(socket.assigns.current_scope)
    assign(socket, :products, products)
  end

@impl true
def render(assigns) do
  ~H"""
    <Component.hero content="Survey">
      Please fill out our survey
    </Component.hero>

    <div class="container mx-auto px-4 py-8 max-w-4xl">
      <%= if @demographic do %>
        <Show.details demographic={@demographic} />
      <% else %>
        <h3>Demographic form coming soon...</h3>
      <% end %>
    </div>

    <div class="mt-6 space-y-4">
      <Component.title_card
        title="Welcome"
        message="Thanks for helping us improve our products."
      />
      <Component.title_card
        title="Reminder"
        message="Only your demographic section is shown for now."
      />
    </div>

    <div class="mt-6">
      <Component.bullet_list
        items={[
          "Demographic details are displaying correctly",
          "Products are already assigned in the LiveView",
          "Ratings behavior will be built in the next chapter"
        ]}
      />
    </div>
  """
  end
end
