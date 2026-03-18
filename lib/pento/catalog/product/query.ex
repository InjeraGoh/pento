defmodule Pento.Catalog.Product.Query do
  import Ecto.Query

  alias Pento.Catalog.Product
  alias Pento.Survey.Rating.Query, as: RatingQuery

  def base, do: Product

  def with_user_ratings(query, user) do
    ratings_query = RatingQuery.preload_user(user)

    from(p in query,
      preload: [ratings: ^ratings_query]
    )
  end
end
