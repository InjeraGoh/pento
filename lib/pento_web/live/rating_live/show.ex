defmodule PentoWeb.RatingLive.Show do
  use Phoenix.Component
  import Phoenix.HTML

  attr :rating, :map, required: true

  def stars(assigns) do
    filled = filled_stars(assigns.rating.stars)
    unfilled = unfilled_stars(assigns.rating.stars)
    all_stars = Enum.concat(filled, unfilled)
    star_display = Enum.join(all_stars, " ")

    assigns = assign(assigns, :star_display, star_display)

    ~H"""
    <div>
      <%= raw(@star_display) %>
    </div>
    """
  end

  def filled_stars(stars) do
    List.duplicate("★", stars)
  end

  def unfilled_stars(stars) do
    List.duplicate("✩", 5 - stars)
  end
end
