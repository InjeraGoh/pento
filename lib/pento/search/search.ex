defmodule Pento.Search.Search do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :sku, :string
  end

  def changeset(search, attrs) do
    search
    |> cast(attrs, [:sku])
    |> validate_required([:sku])
    |> validate_length(:sku, min: 7)
  end
end
