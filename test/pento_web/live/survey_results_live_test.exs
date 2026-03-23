defmodule PentoWeb.SurveyResultsLiveTest do
  use PentoWeb.ConnCase

  alias PentoWeb.Admin.SurveyResultsLive
  alias Pento.Accounts
  alias Pento.Catalog
  alias Pento.Survey

  @create_product_attrs %{
    description: "test description",
    name: "Test Game",
    sku: 123456,
    unit_price: 120.5
  }

  @create_user_attrs %{
    email: "test@test.com",
    password: "passwordpassword",
    username: "testuser"
  }

  @create_user2_attrs %{
    email: "another-person@email.com",
    password: "passwordpassword",
    username: "anotheruser"
  }

  @create_demographic_attrs %{
    gender: "female",
    year_of_birth: 2010,
    education_level: "high school"
  }

  @create_demographic2_attrs %{
    gender: "male",
    year_of_birth: 1996,
    education_level: "bachelor's degree"
  }

  defp product_fixture(scope) do
    {:ok, product} = Catalog.create_product(scope, @create_product_attrs)
    product
  end

  def user_fixture(attrs \\ @create_user_attrs) do
    {:ok, user} = Accounts.register_user(attrs)
    user
  end

  defp demographic_fixture(scope, user, attrs \\ @create_demographic_attrs) do
    attrs =
      attrs
      |> Map.merge(%{user_id: user.id})

    {:ok, demographic} = Survey.create_demographic(scope, attrs)
    demographic
  end

  defp rating_fixture(scope, stars, user, product) do
    {:ok, rating} =
      Survey.create_rating(scope, %{
        stars: stars,
        user_id: user.id,
        product_id: product.id
      })

    rating
  end

  defp create_product(%{scope: scope}) do
    product = product_fixture(scope)
    %{product: product}
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end

  defp create_rating(scope, stars, user, product) do
    rating = rating_fixture(scope, stars, user, product)
    %{rating: rating}
  end

  defp create_demographic(scope, user) do
    demographic = demographic_fixture(scope, user)
    %{demographic: demographic}
  end

defp create_socket(_) do
  %{socket: %Phoenix.LiveView.Socket{assigns: %{__changed__: %{}}}}
end

defp update_socket(socket, key, value) do
  %{socket | assigns: Map.merge(socket.assigns, %{key => value})}
end

defp assert_keys(socket, key, value) do
  assert socket.assigns[key] == value
  socket
end

  describe "Socket state" do
    setup [
      :create_user,
      :create_socket,
      :register_and_log_in_user,
      :create_product
    ]

    setup %{user: user, scope: scope} do
      create_demographic(scope, user)
      user2 = user_fixture(@create_user2_attrs)
      scope2 = Accounts.Scope.for_user(user2)
      demographic_fixture(scope2, user2, @create_demographic2_attrs)
      [user2: user2, scope2: scope2]
    end

    test "no ratings exist", %{socket: socket} do
      socket =
        socket
        |> SurveyResultsLive.assign_age_group_filter()
        |> SurveyResultsLive.assign_gender_filter()
        |> SurveyResultsLive.assign_products_with_average_ratings()

      assert socket.assigns.products_with_average_ratings == [{"Test Game", 0}]
    end

     test "ratings exist", %{
      socket: socket,
      product: product,
      user: user,
      scope: scope
    } do
      create_rating(scope, 2, user, product)

      socket =
        socket
        |> SurveyResultsLive.assign_age_group_filter()
        |> SurveyResultsLive.assign_gender_filter()
        |> SurveyResultsLive.assign_products_with_average_ratings()

      assert socket.assigns.products_with_average_ratings == [
               {"Test Game", 2.0}
             ]
    end

    test "ratings are filtered by age group", %{
      socket: socket,
      user: user,
      product: product,
      user2: user2,
      scope: scope,
      scope2: scope2
    } do
      create_rating(scope, 2, user, product)
      create_rating(scope2, 3, user2, product)

      socket
      |> SurveyResultsLive.assign_age_group_filter()
      |> assert_keys(:age_group_filter, "all")
      |> update_socket(:age_group_filter, "18 and under")
      |> SurveyResultsLive.assign_age_group_filter()
      |> assert_keys(:age_group_filter, "18 and under")
      |> SurveyResultsLive.assign_gender_filter()
      |> SurveyResultsLive.assign_products_with_average_ratings()
      |> assert_keys(:products_with_average_ratings, [{"Test Game", 2.0}])
    end
  end

end
