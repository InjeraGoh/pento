defmodule Pento.Promo.Recipient do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :first_name, :string
    field :email, :string
  end

  def changeset(recipient, attrs) do
    recipient
    |> cast(attrs, [:first_name, :email])
    |> validate_required([:first_name, :email])
    # |> validate_format(:email, ~r/@/)
    |> validate_format(:email, ~r/^[^@\s]+@[^@\s]+\.[^@\s]+$/)
  end

end
