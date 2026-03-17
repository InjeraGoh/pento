defmodule Pento.Search do
  alias Pento.Search.Search

  def change_search(%Search{} = search, attrs \\ %{}) do
    Search.changeset(search, attrs)
  end

  def search_by_sku(%Search{} = search, attrs) do
    search
    |> Search.changeset(attrs)
    |> Ecto.Changeset.apply_action(:validate)
  end
end
