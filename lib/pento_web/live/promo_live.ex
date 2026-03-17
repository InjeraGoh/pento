defmodule PentoWeb.PromoLive do
  use PentoWeb, :live_view

  alias Pento.Promo
  alias Pento.Promo.Recipient

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign_recipient()
     |> clear_form()}
  end

  @impl true
  def handle_event("validate", %{"recipient" => recipient_params}, socket) do
    changeset =
      %Recipient{}
      |> Promo.change_recipient(recipient_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"recipient" => recipient_params}, socket) do
    case Promo.send_promo(socket.assigns.recipient, recipient_params) do
      {:ok, _recipient} ->
        {:noreply,
        socket
        |> put_flash(:info, "Promo sent successfully!")
        |> assign_recipient()
        |> clear_form()}

      {:error, changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def assign_recipient(socket) do
    socket
    |> assign(:recipient, %Recipient{})
  end

  def clear_form(socket) do
    changeset =
    socket.assigns.recipient
    |> Promo.change_recipient()

    socket |> assign_form(changeset)
  end

  def assign_form(socket, changeset) do
    assign(socket, :form, to_form(changeset))
  end

end
