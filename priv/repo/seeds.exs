# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#

alias Pento.{Accounts, Catalog}
alias Pento.Accounts.Scope

# Create a seed user for development
{:ok, user} =
  Accounts.register_user(%{
    email: "seed4@example.com",
    username: "seeduser4",
  })

# Get the scope for this user
scope = Scope.for_user(user)
# scope = Pento.Accounts.Scope.for_user(user)
# scope = Accounts.get_scope_for_user(user.id)

# Create sample products
products = [
  %{
    name: "Chess",
    description: "The classic strategy game",
    unit_price: 10.00,
    sku: 567891
  },
  %{
    name: "Checkers",
    description: "A classic board game",
    unit_price: 8.00,
    sku: 123456
  },
  %{
    name: "Backgammon",
    description: "An ancient strategy game",
    unit_price: 15.00,
    sku: 987654
  }
]

Enum.each(products, fn product_attrs ->
  {:ok, product} = Catalog.create_product(scope, product_attrs)
  IO.puts("Created product: #{product.name}")
end)
