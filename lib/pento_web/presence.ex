defmodule PentoWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.
  """

  use Phoenix.Presence,
    otp_app: :pento,
    pubsub_server: Pento.PubSub

  @user_activity_topic "user_activity"
  @survey_takers_topic "survey_takers"

  def track_user(pid, product, user_email) do
    track(
      pid,
      @user_activity_topic,
      product.name,
      %{users: [%{email: user_email}]}
    )
  end

  def list_products_and_users do
    list(@user_activity_topic)
    |> Enum.map(&extract_product_with_users/1)
  end

  defp extract_product_with_users({product_name, %{metas: metas}}) do
    {product_name, users_from_metas_list(metas)}
  end

  def track_survey_taker(pid, user_email) do
    track(
      pid,
      @survey_takers_topic,
      "survey",
      %{users: [%{email: user_email}]}
    )
  end

  def list_survey_takers do
    case list(@survey_takers_topic) do
      %{"survey" => %{metas: metas}} ->
        users_from_metas_list(metas)

      _ ->
        []
    end
  end

  def survey_takers_count do
    list_survey_takers()
    |> length()
  end

  defp users_from_metas_list(metas_list) do
    metas_list
    |> Enum.map(&users_from_meta_map/1)
    |> List.flatten()
    |> Enum.uniq()
  end

  defp users_from_meta_map(meta_map) do
    get_in(meta_map, [:users])
  end
end
