defmodule PentoWeb.SurveyLive do
  use PentoWeb, :live_view

  alias Pento.{Survey, Catalog}
  alias PentoWeb.DemographicLive.{Show, Form}
  alias PentoWeb.RatingLive.Index
  alias Phoenix.LiveView.JS
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
    <Layouts.flash_group flash={@flash} />

    <Component.hero content="Survey">
      Please fill out our survey
    </Component.hero>

    <div class="container mx-auto px-4 py-8 max-w-4xl">
      <%= if @demographic do %>
        <Show.details demographic={@demographic} />
        <Index.product_list products={@products} current_scope={@current_scope} />
      <% else %>
        <.live_component
          module={Form}
          id="demographic-form"
          current_scope={@current_scope}
        />
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
      <.live_component
        module={PentoWeb.ToggleLive.Panel}
        id="demo-toggle"
      />
    </div>

    <div class="mt-6 rounded border p-4">
      <button
        class="btn btn-primary"
        phx-click={JS.toggle(to: "#extra-info")}
      >
        Toggle Extra Info
      </button>

      <div id="extra-info" class="hidden mt-4 rounded border p-3">
        This content is toggled in the browser only, with no server round-trip.
      </div>
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

  @impl true
  def handle_info({:created_demographic, demographic}, socket) do
    socket = handle_demographic_created(socket, demographic)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:created_rating, product, product_index}, socket) do
    socket = handle_rating_created(socket, product, product_index)
    {:noreply, socket}
  end

  defp handle_demographic_created(socket, demographic) do
    socket
    |> put_flash(:info, "Demographic created successfully")
    |> assign(:demographic, demographic)
  end

  defp handle_rating_created(socket, product, product_index) do
    current_products = socket.assigns.products
    products = List.replace_at(current_products, product_index, product)

    socket
    |> put_flash(:info, "Rating created successfully")
    |> assign(:products, products)
  end
end
