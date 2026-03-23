defmodule PentoWeb.SurveyLiveTest do
  use PentoWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "demographic form" do
    setup [:register_and_log_in_user]

    test "submitting a new demographic updates the page", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/survey")

      params = %{
        "demographic" => %{
          "gender" => "female",
          "year_of_birth" => "2010",
          "education_level" => "high school"
        }
      }

      html =
        view
        |> element("#demographic-form")
        |> render_submit(params)

      assert html =~ "female"
      assert html =~ "2010"
      assert html =~ "high school"
    end
  end
end
