# Run this script with: mix run priv/repo/rating_seeds.exs

alias Pento.{Repo, Accounts, Survey}
alias Pento.Accounts.{User, Scope}
alias Pento.Survey.{Demographic, Rating}
alias Pento.Catalog.Product

users =
  for i <- 1..43 do
    Accounts.register_user(%{
      email: "user#{i}@example.com",
      password: "passwordpassword"
    })
  end

user_ids = Repo.all(User) |> Enum.map(& &1.id)

product_ids = Repo.all(Product) |> Enum.map(& &1.id)
genders = ["male", "female", "other", "prefer not to say"]
years = 1950..2005 |> Enum.to_list()
stars = 1..5 |> Enum.to_list()

for user_id <- user_ids do
  scope = %Scope{user: %User{id: user_id}}
  gender = Enum.random(genders)
  year_of_birth = Enum.random(years)

  Survey.create_demographic(scope, %{
    gender: gender,
    year_of_birth: year_of_birth
  })
end

for uid <- user_ids, pid <- product_ids do
  Survey.create_rating(%{
    user_id: uid,
    product_id: pid,
    stars: Enum.random(stars)
  })
end
