defmodule PentoWeb.DemographicLive.Show do
  use Phoenix.Component
  alias PentoWeb.CoreComponents

  attr :demographic, :map, required: true

  def details(assigns) do
    ~H"""
    <h2 class="font-medium text-2xl">Demographics ✓</h2>
    <CoreComponents.table id="demographics" rows={[@demographic]}>
      <:col :let={demographic} label="Gender">
        <%= demographic.gender %>
      </:col>
      <:col :let={demographic} label="Year of Birth">
        <%= demographic.year_of_birth %>
      </:col>
    </CoreComponents.table>
    """
  end
end
