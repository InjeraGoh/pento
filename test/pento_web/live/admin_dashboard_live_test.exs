defmodule PentoWeb.AdminDashboardLiveTest do
  use PentoWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Pento.Accounts
  alias Pento.Survey
  alias Pento.Catalog

  @create_product_attrs %{
    description: "test description",
    name: "Test Game",
    sku: 123456,
    unit_price: 120.5
  }

  @create_demographic_attrs %{
    gender: "female",
    year_of_birth: 2010,
    education_level: "high school"
  }

  @create_demographic_over_18_attrs %{
    gender: "female",
    year_of_birth: 1996,
    education_level: "bachelor's degree"
  }

  @create_user_attrs %{
    email: "test@test.com",
    password: "passwordpassword",
    username: "testuser"
  }

  @create_user2_attrs %{
    email: "test2@test.com",
    password: "passwordpassword",
    username: "testuser2"
  }

  @create_user3_attrs %{
    email: "test3@test.com",
    password: "passwordpassword",
    username: "testuser3"
  }

  defp product_fixture(scope) do
    {:ok, product} = Catalog.create_product(scope, @create_product_attrs)
    product
  end

  defp user_fixture(attrs \\ @create_user_attrs) do
    {:ok, user} = Accounts.register_user(attrs)
    user
  end

  defp demographic_fixture(scope, user, attrs) do
    attrs =
      attrs
      |> Map.merge(%{user_id: user.id})

    {:ok, demographic} = Survey.create_demographic(scope, attrs)
    demographic
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

  defp create_product(%{scope: scope}) do
    product = product_fixture(scope)
    %{product: product}
  end

  defp create_user(_) do
    user = user_fixture()
    %{user: user}
  end

  defp create_demographic(scope, user, attrs \\ @create_demographic_attrs) do
    demographic = demographic_fixture(scope, user, attrs)
    %{demographic: demographic}
  end

  defp create_rating(scope, user, product, stars) do
    rating = rating_fixture(scope, user, product, stars)
    %{rating: rating}
  end

  describe "Survey Results" do
    setup [:register_and_log_in_user, :create_product, :create_user]

    setup %{user: user, product: product, scope: scope} do
      create_demographic(scope, user)
      create_rating(scope, user, product, 2)

      user2 = user_fixture(@create_user2_attrs)
      scope2 = Accounts.Scope.for_user(user2)
      create_demographic(scope2, user2, @create_demographic_over_18_attrs)
      create_rating(scope2, user2, product, 3)

      :ok
    end

    test "it filters by age group", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/admin/dashboard")

      params = %{"age_group_filter" => "18 and under"}

      assert view
             |> element("#age-group-form")
             |> render_change(params) =~ "<title>2.00</title>"
    end

    test "it updates to display newly created ratings", %{conn: conn, product: product} do
      {:ok, view, html} = live(conn, "/admin/dashboard")
      assert html =~ "<title>2.50</title>"

      user3 = user_fixture(@create_user3_attrs)
      scope3 = Accounts.Scope.for_user(user3)
      create_demographic(scope3, user3)
      create_rating(scope3, user3, product, 3)

      send(view.pid, %{event: "rating_created"})
      :timer.sleep(2)

      assert render(view) =~ "<title>2.67</title>"
    end
  end
end
