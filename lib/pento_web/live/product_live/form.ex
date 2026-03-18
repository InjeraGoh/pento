defmodule PentoWeb.ProductLive.Form do
  use PentoWeb, :live_view

  alias Pento.Catalog
  alias Pento.Catalog.Product

  @impl true
  def render(assigns) do
    ~H"""

    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage product records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="product-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:unit_price]} type="number" label="Unit price" step="any" />
        <.input field={@form[:sku]} type="number" label="Sku" />

        <div phx-drop-target={@uploads.image.ref} class="border-2 border-dashed border-gray-300 rounded-lg p-6">
          <label for={@uploads.image.ref} class="block text-sm font-medium">
            Product Image
          </label>
          <.live_file_input upload={@uploads.image} />
        </div>
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Product</.button>
          <.button navigate={return_path(@current_scope, @return_to, @product)}>Cancel</.button>
        </footer>

      </.form>

        <div :for={entry <- @uploads.image.entries}>
          <div class="bg-blue-100 border border-blue-400 text-blue-700 px-4 py-3 rounded">
            <.live_img_preview entry={entry} class="w-20 h-20 object-cover mb-2" />
            <p>{entry.client_name} - {entry.progress}%</p>

            <button
              type="button"
              phx-click="cancel-upload"
              phx-value-ref={entry.ref}
              class="mt-2 rounded bg-red-600 px-3 py-2 text-white"
            >
              Cancel
            </button>
          </div>
        </div>

        <div :if={Enum.empty?(@uploads.image.entries) && @product.image_upload}>
          <div class="bg-blue-100 border border-blue-400 text-blue-700 px-4 py-3 rounded">
            <img src={@product.image_upload} alt="Current product image" class="w-20 h-20 object-cover mb-2" />
            <p>Current image</p>
          </div>
        </div>

        <div :for={err <- upload_errors(@uploads.image)}
          class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
          Upload error: {upload_error_to_string(err)}
        </div>

        <div :for={entry <- @uploads.image.entries}>
          <div :for={err <- upload_errors(@uploads.image, entry)}
            class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded">
            {upload_image_error(err)}
          </div>
        </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> allow_upload(:image,
          accept: ~w(.jpg .jpeg .png),
          max_entries: 1,
          max_file_size: 9_000_000,
          auto_upload: true
        )
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    product = Catalog.get_product!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, product)
    # |> assign(:form, to_form(Catalog.change_product(socket.assigns.current_scope, product)))
    |> assign_form(Catalog.change_product(socket.assigns.current_scope, product))
  end

  defp apply_action(socket, :new, _params) do
    product = %Product{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Product")
    |> assign(:product, product)
    # |> assign(:form, to_form(Catalog.change_product(socket.assigns.current_scope, product)))
    |> assign_form(Catalog.change_product(socket.assigns.current_scope, product))
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset = Catalog.change_product(socket.assigns.current_scope, socket.assigns.product, product_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    product_params = params_with_image(socket, product_params)
    save_product(socket, socket.assigns.live_action, product_params)
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  defp save_product(socket, :edit, product_params) do
    case Catalog.update_product(socket.assigns.current_scope, socket.assigns.product, product_params) do
      {:ok, product} ->
      {:noreply,
        socket
        |> put_flash(:info, "Product updated successfully")
        |> push_navigate(
          to: return_path(socket.assigns.current_scope, socket.assigns.return_to, product)
        )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_product(socket, :new, product_params) do
    case Catalog.create_product(socket.assigns.current_scope, product_params) do
      {:ok, product} ->
        {:noreply,
         socket
         |> put_flash(:info, "Product created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, product)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp upload_error_to_string(:too_large), do: "File is too large"
  defp upload_error_to_string(:not_accepted), do: "Invalid file type"
  defp upload_error_to_string(:too_many_files), do: "Too many files"

  defp upload_image_error(:too_large), do: "File is too large"
  defp upload_image_error(:not_accepted), do: "Invalid file type"
  defp upload_image_error(:too_many_files), do: "Too many files"

  defp params_with_image(socket, params) do
    path =
      socket
      |> consume_uploaded_entries(:image, &upload_static_file/2)
      |> List.first()

    if path do
      Map.put(params, "image_upload", path)
    else
      params
    end
  end

  defp upload_static_file(%{path: path}, _entry) do
    filename = Path.basename(path)
    dest = Path.join("priv/static/images", filename)
    File.cp!(path, dest)

    {:ok, ~p"/images/#{filename}"}
  end

  defp return_path(_scope, "index", _product), do: ~p"/products"
  defp return_path(_scope, "show", product), do: ~p"/products/#{product}"
end
