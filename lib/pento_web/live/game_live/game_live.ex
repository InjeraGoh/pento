defmodule PentoWeb.GameLive do
  use PentoWeb, :live_view

  alias PentoWeb.GameLive.Board
  alias PentoWeb.GameLive.GameInstructions
  import PentoWeb.GameLive.Component

  def mount(%{"puzzle" => puzzle}, _session, socket) do
    {:ok, assign(socket, puzzle: puzzle)}
  end

  def render(assigns) do
    ~H"""
    <section class="mx-auto max-w-4xl px-4 py-8">
      <h1 class="font-heavy text-3xl mb-6">Welcome to Pento!</h1>
      <GameInstructions.show />
      <.live_component module={Board} puzzle={@puzzle} id="board-component" />
      <div class="mt-8 max-w-xs">
        <.control_panel view_box="0 0 200 40">
          <.triangle x={94} y={-2} fill="#B9D7DA" rotate={0} />
          <.triangle x={94} y={-2} fill="#B9D7DA" rotate={90} />
          <.triangle x={94} y={-2} fill="#B9D7DA" rotate={180} />
          <.triangle x={94} y={-2} fill="#B9D7DA" rotate={270} />
        </.control_panel>
      </div>
    </section>
    """
  end
end
