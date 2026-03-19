defmodule PentoWeb.Admin.SurveyTakersLive do
  use PentoWeb, :live_component

  alias PentoWeb.Presence

  def update(_assigns, socket) do
    {:ok,
     socket
     |> assign_survey_takers()}
  end

  defp assign_survey_takers(socket) do
    survey_takers = Presence.list_survey_takers()

    socket
    |> assign(:survey_takers, survey_takers)
    |> assign(:survey_takers_count, length(survey_takers))
  end
end
