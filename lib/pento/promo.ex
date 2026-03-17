defmodule Pento.Promo do
  alias Pento.Promo.Recipient
  alias Pento.Accounts.UserNotifier

  def change_recipient(%Recipient{} = recipient, attrs \\ %{}) do
    Recipient.changeset(recipient, attrs)
  end

  def send_promo(recipient, attrs) do
  recipient
  |> Recipient.changeset(attrs)
  |> Ecto.Changeset.apply_action(:insert)
  |> case do
    {:ok, recipient} ->
      UserNotifier.deliver_promotion(recipient, attrs["url"] || attrs[:url])

    {:error, changeset} ->
      {:error, changeset}
  end

  # |> change_recipient(attrs)
  # |> Ecto.Changeset.apply_action(:update)
  end

end
