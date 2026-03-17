defmodule PentoWeb.SearchLive do
  use PentoWeb, :live_view

  alias Pento.Search
  alias Pento.Search.Search, as: SearchForm

  @impl true
  def mount(_params, _session, socket) do
    changeset = Search.change_search(%SearchForm{})

    {:ok,
     socket
     |> assign(:page_title, "Search by SKU")
     |> assign(:form, to_form(changeset))}
  end

  @impl true
  def handle_event("validate", %{"search" => search_params}, socket) do
    changeset =
      %SearchForm{}
      |> Search.change_search(search_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("search", %{"search" => search_params}, socket) do
    case Search.search_by_sku(%SearchForm{}, search_params) do
      {:ok, _search} ->
        {:noreply,
         socket
         |> put_flash(:info, "Search submitted successfully")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Search by SKU
        <:subtitle>Search for a product using its SKU.</:subtitle>
      </.header>

    <.form for={@form} id="search-form" phx-change="validate" phx-submit="search">
      <.input field={@form[:sku]} type="text" label="SKU" />
      <div class="mt-4">
        <.button>Search</.button>
      </div>
    </.form>
    </Layouts.app>
    """
  end
end
