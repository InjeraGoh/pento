defmodule PentoWeb.ProductLive.Show do
  use PentoWeb, :live_view

  alias Pento.Catalog
  alias PentoWeb.Presence

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Product {@product.id}
        <:subtitle>This is a product record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/products"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/products/#{@product}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit product
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@product.name}</:item>
        <:item title="Description">{@product.description}</:item>
        <:item title="Unit price">{@product.unit_price}</:item>
        <:item title="Sku">{@product.sku}</:item>
      </.list>

      <div>
        <img
          :if={@product.image_upload}
          alt="product image"
          width="400"
          src={@product.image_upload}
        />
      </div>

      <p class="mt-4 text-sm text-gray-700">
        {@my_message}
      </p>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    product = Catalog.get_product!(socket.assigns.current_scope, id)

    if connected?(socket) do
      Catalog.subscribe_products(socket.assigns.current_scope)
      maybe_track_user(product, socket)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Product")
     |> assign(:product, product)
     |> assign(:my_message, "Hello! You are viewing this product from ProductLive.Show.")}
  end

  defp maybe_track_user(
         product,
         %{assigns: %{current_scope: current_scope}} = socket
       ) do
    if connected?(socket) do
      Presence.track_user(self(), product, current_scope.user.email)
    end
  end

  @impl true
  def handle_info(
        {:updated, %Pento.Catalog.Product{id: id} = product},
        %{assigns: %{product: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :product, product)}
  end

  def handle_info(
        {:deleted, %Pento.Catalog.Product{id: id}},
        %{assigns: %{product: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current product was deleted.")
     |> push_navigate(to: ~p"/products")}
  end

  def handle_info({type, %Pento.Catalog.Product{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
