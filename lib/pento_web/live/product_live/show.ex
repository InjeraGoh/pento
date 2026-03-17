defmodule PentoWeb.ProductLive.Show do
  use PentoWeb, :live_view

  alias Pento.Catalog

  ## Chapter 4 Q4: How does the Show template render the Product Edit form?
  ## It navigates to the edit route VIA 'edit product' button (which links to PentoWeb.ProductLIve.Edit in Router.ex)

  ## The ProductLive.Show template does not render the edit form directly.
  ## It navigates to /products/:id/edit?return_to=show, which loads ProductLive.Edit.
  ## That page renders the form, and the form supports "validate" and "save" events.

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

      <%!-- Chapter 4 extra task --%>
      <p class="mt-4 text-sm text-gray-700">
        {@my_message}
      </p>

    </Layouts.app>
    """
  end

  ## Chapter 4 Q2: What data does ProductLive.Show.mount/3 add to the socket?
  ## Assigns :page_title and :product to the socket.
  ## mount/3 assigns :page_title and :product to the socket.



  ## Chapter 4 Q3: How does the ProductLive.Show live view use the handle_params/3 callback?
  ## IN my version of Phoenix it is not used. URL Parameters are handled in the mount/3 callback.

  ## Step 1: SUbscribes to Product Updates events.
  ## Step 2: Assigns Page Title
  ## Step 3: Fetch Product via Catalog.get_product!/2
  ## Step 4: Store Product in Socket via @product.

  ## In my generated version, handle_params/3 is not used.
  ## Instead, the "id" route parameter is handled directly in mount/3, which fetches and assigns the product.


  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Catalog.subscribe_products(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Product")
     |> assign(:product, Catalog.get_product!(socket.assigns.current_scope, id))

      #  Chapter 4 extra task
     |> assign(:my_message, "Hello! You are viewing this product from ProductLive.Show.")}
  end

  @impl true
  @spec handle_info(
        {:created, %Pento.Catalog.Product{}}
        | {:deleted, %Pento.Catalog.Product{}}
        | {:updated, %Pento.Catalog.Product{}}, Phoenix.LiveView.Socket.t()) :: {:noreply, Phoenix.LiveView.Socket.t()}
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
