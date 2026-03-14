defmodule Pento.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :description, :string
    field :unit_price, :float
    field :sku, :integer
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs, user_scope) do
    product
    |> cast(attrs, [:name, :description, :unit_price, :sku])
    |> validate_required([:name, :description, :unit_price, :sku])
    |> unique_constraint(:sku)
    |> validate_number(:unit_price, greater_than: 0.0)
    |> put_change(:user_id, user_scope.user.id)
  end

  # Chapter 3 (Pg 103) - Exercise 3.2 - Add a markdown_changeset/2 function to the Product schema that takes a product and a markdown amount, and returns a changeset with the unit price reduced by the markdown amount. Ensure that the new price is not negative.
  def markdown_changeset(product, markdown_amount) do
    new_price = product.unit_price - markdown_amount

    product
    |> change(%{unit_price: new_price})
    |> validate_number(:unit_price, greater_than_or_equal_to: 0)
    |> validate_markdown_amount(markdown_amount)
  end

  defp validate_markdown_amount(changeset, markdown_amount) do
    cond do
      not is_number(markdown_amount) ->
        add_error(changeset, :unit_price, "markdown amount must be a number")

      markdown_amount <= 0 ->
        add_error(changeset, :unit_price, "markdown amount must be greater than 0")

      markdown_amount > changeset.data.unit_price ->
        add_error(changeset, :unit_price, "markdown amount cannot be greater than current price")

      true ->
        changeset
    end
  end

end
