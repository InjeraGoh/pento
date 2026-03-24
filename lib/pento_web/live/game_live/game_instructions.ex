defmodule PentoWeb.GameLive.GameInstructions do
  use Phoenix.Component

  def show(assigns) do
    ~H"""
    <p class="mb-6 text-sm leading-6">
      Pick a pentomino from the palette below. Use the keyboard later to move,
      rotate, and place pieces on the board.
    </p>
    """
  end
end
