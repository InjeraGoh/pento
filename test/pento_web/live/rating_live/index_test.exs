defmodule PentoWeb.RatingLive.IndexTest do
  use PentoWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Pento.Accounts
  alias Pento.Catalog
  alias Pento.Survey
  alias PentoWeb.RatingLive.Index

  @create_product_attrs %{
    description: "test description",
    name: "Test Game",
    sku: 123456,
    unit_price: 120.5
  }

  @create_user_attrs %{
    email: "rating@test.com",
    password: "passwordpassword",
    username: "ratinguser"
  }

  defp user_fixture(attrs \\ @create_user_attrs) do
    {:ok, user} = Accounts.register_user(attrs)
    user
  end

  defp product_fixture(scope) do
    {:ok, product} = Catalog.create_product(scope, @create_product_attrs)
    product
  end

  defp rating_fixture(scope, user, product, stars) do
    {:ok, rating} =
      Survey.create_rating(scope, %{
        stars: stars,
        user_id: user.id,
        product_id: product.id
      })

    rating
  end

  describe "product_rating/1" do
    setup do
      user = user_fixture()
      scope = Accounts.Scope.for_user(user)
      product = product_fixture(scope)

      [user: user, scope: scope, product: product]
    end

    test "renders rating form when no product rating exists", %{
      product: product,
      scope: scope
    } do
      product = %{product | ratings: []}

      html =
        render_component(&Index.product_rating/1, %{
          product: product,
          index: 0,
          current_scope: scope
        })

      assert html =~ "Test Game"
      assert html =~ "rating-form-#{product.id}"
    end

    test "renders rating details when rating exists", %{
      scope: scope,
      user: user,
      product: product
    } do
      rating = rating_fixture(scope, user, product, 4)
      product = %{product | ratings: [rating]}

      html =
        render_component(&Index.product_rating/1, %{
          product: product,
          index: 0,
          current_scope: scope
        })

      assert html =~ "Test Game"
      assert html =~ "★ ★ ★ ★ ✩"
      refute html =~ "rating-form-#{product.id}"
    end
  end
end
