defmodule PentoWeb.GameLive.Board do
  use PentoWeb, :live_component

  alias Pento.Game.Board
  alias Pento.Game
  import PentoWeb.GameLive.{Colors, Component}

  def handle_event("pick", %{"name" => _name}, %{assigns: %{gave_up: true}} = socket) do
    {:noreply, socket}
  end

  def handle_event("pick", %{"name" => _name}, %{assigns: %{won: true}} = socket) do
    {:noreply, socket}
  end

  def handle_event("pick", %{"name" => name}, socket) do
    {:noreply, socket |> pick(name) |> assign_shapes}
  end

  def handle_event("key", %{"key" => _key}, %{assigns: %{gave_up: true}} = socket) do
    {:noreply, socket}
  end

  def handle_event("key", %{"key" => _key}, %{assigns: %{won: true}} = socket) do
    {:noreply, socket}
  end

  def handle_event("key", %{"key" => key}, socket) do
    {:noreply, socket |> do_key(key) |> assign_shapes}
  end

  def handle_event("give-up", _params, socket) do
    {:noreply, assign(socket, gave_up: true)}
  end

  def do_key(socket, key) do
    case key do
      " " -> drop(socket)
      "ArrowLeft" -> move(socket, :left)
      "ArrowRight" -> move(socket, :right)
      "ArrowUp" -> move(socket, :up)
      "ArrowDown" -> move(socket, :down)
      "Shift" -> move(socket, :rotate)
      "Enter" -> move(socket, :flip)
      "Space" -> drop(socket)
      _ -> socket
    end
  end

  def move(socket, move) do
    case Game.maybe_move(socket.assigns.board, move) do
      {:error, message} ->
        put_flash(socket, :info, message)

      {:ok, board} ->
        socket
        |> assign(board: board, score: socket.assigns.score - 1)
        |> assign_shapes()
    end
  end

  def drop(socket) do
    case Game.maybe_drop(socket.assigns.board) do
      {:error, message} ->
        put_flash(socket, :info, message)

      {:ok, board} ->
        socket
        |> assign(board: board, score: socket.assigns.score + 500, won: Board.won?(board))
        |> assign_shapes()
    end
  end

  def pick(socket, name) do
    shape_name = String.to_existing_atom(name)
    {:ok, board} = Game.pick(socket.assigns.board, shape_name)
    assign(socket, board: board)
  end

  def update(%{puzzle: puzzle, id: id}, socket) do
    {:ok,
     socket
     |> assign_params(id, puzzle)
     |> assign_board()
     |> assign_shapes()}
  end

  def assign_params(socket, id, puzzle) do
    assign(socket, id: id, puzzle: puzzle)
  end

  def assign_board(%{assigns: %{puzzle: puzzle}} = socket) do
    puzzle_atom = String.to_atom(puzzle)

    board =
      if puzzle_atom in Board.puzzles() do
        Board.new(puzzle_atom)
      else
        Board.new(:default)
      end

    assign(socket, board: board, score: 0, won: false, gave_up: false)
  end

  def assign_shapes(%{assigns: %{board: board}} = socket) do
    shapes = Board.to_shapes(board)
    assign(socket, shapes: shapes)
  end

  def render(assigns) do
  ~H"""
  <div id={@id} phx-window-keydown="key" phx-target={@myself}>
    <div class="mb-4 text-lg font-semibold">
      Score: {@score}
    </div>

    <%= if !@won and !@gave_up do %>
      <div class="mb-4">
        <button
          phx-click="give-up"
          phx-target={@myself}
          class="rounded bg-red-600 px-4 py-2 text-white"
        >
          Give Up
        </button>
      </div>
    <% end %>

    <%= if @won do %>
      <div class="mb-4 text-xl font-bold text-green-400">
        You Won!
      </div>
    <% end %>

    <%= if @gave_up do %>
      <div class="mb-4 text-xl font-bold text-red-400">
        You gave up.
      </div>
    <% end %>

    <.canvas view_box="0 0 200 140">
      <%= for shape <- @shapes do %>
        <.shape
          points={shape.points}
          fill={color(shape.color, Board.active?(@board, shape.name), false)}
          name={shape.name}
        />
      <% end %>
    </.canvas>

    <hr />

    <.palette
      shape_names={@board.palette}
      completed_shape_names={Enum.map(@board.completed_pentos, & &1.name)}
    />
  </div>
  """
end
end
