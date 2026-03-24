defmodule PentoWeb.GameLive.Component do
  use Phoenix.Component

  import PentoWeb.GameLive.Colors

  @width 10

  attr :x, :integer, required: true
  attr :y, :integer, required: true
  attr :fill, :string
  attr :name, :string
  attr :"phx-click", :string
  attr :"phx-value", :string
  attr :"phx-target", :any

  def point(assigns) do
    ~H"""
    <use
      xlink:href="#pento-point"
      x={convert(@x)}
      y={convert(@y)}
      fill={@fill}
      phx-click="pick"
      phx-value-name={@name}
      phx-target="#board-component"
    />
    """
  end

  attr :points, :list, required: true
  attr :name, :string, required: true
  attr :fill, :string, required: true

  def shape(assigns) do
    ~H"""
    <%= for {x, y} <- @points do %>
      <.point x={x} y={y} fill={@fill} name={@name} />
    <% end %>
    """
  end

  attr :view_box, :string
  slot :inner_block, required: true

  def canvas(assigns) do
    ~H"""
    <svg viewBox={@view_box}>
      <defs>
        <rect id="pento-point" width="10" height="10" />
      </defs>
      {render_slot(@inner_block)}
    </svg>
    """
  end

  attr :shape_names, :list, required: true
  attr :completed_shape_names, :list, default: []

  def palette(assigns) do
    ~H"""
    <div id="pento-palette">
      <svg viewBox="0 0 500 125">
        <defs>
          <rect id="palette-point" width="10" height="10" />
        </defs>

        <%= for shape <- palette_shapes(@shape_names) do %>
          <.palette_shape
            points={shape.points}
            fill={color(shape.color, false, shape.name in @completed_shape_names)}
            name={shape.name}
          />
        <% end %>

      </svg>
    </div>
    """
  end

  attr :points, :list, required: true
  attr :name, :string, required: true
  attr :fill, :string, required: true

  def palette_shape(assigns) do
    ~H"""
    <%= for {x, y} <- @points do %>
      <.palette_point x={x} y={y} fill={@fill} name={@name} />
    <% end %>
    """
  end

  attr :x, :integer, required: true
  attr :y, :integer, required: true
  attr :fill, :string, required: true
  attr :name, :string, required: true

  def palette_point(assigns) do
    ~H"""
    <use
      xlink:href="#palette-point"
      x={convert(@x)}
      y={convert(@y)}
      fill={@fill}
      phx-click="pick"
      phx-value-name={@name}
      phx-target="#board-component"
    />
    """
  end

  attr :view_box, :string, required: true
  slot :inner_block, required: true

  def control_panel(assigns) do
    ~H"""
    <svg viewBox={@view_box}>
      <defs>
        <polygon id="triangle" points="6.25 1.875, 12.5 12.5, 0 12.5" />
      </defs>
      {render_slot(@inner_block)}
    </svg>
    """
  end

  attr :x, :integer, required: true
  attr :y, :integer, required: true
  attr :fill, :string, required: true
  attr :rotate, :integer, required: true

  def triangle(assigns) do
    ~H"""
    <use
      href="#triangle"
      x={@x}
      y={@y}
      transform={"rotate(#{@rotate}, 100, 20)"}
      fill={@fill}
    />
    """
  end

  defp palette_shapes(names) do
    names
    |> Enum.with_index()
    |> Enum.map(&place_pento/1)
  end

  defp place_pento({name, i}) do
    Pento.Game.Pentomino.new(name: name, location: location(i))
    |> Pento.Game.Pentomino.to_shape()
  end

  defp location(i) do
    x = rem(i, 6) * 4 + 3
    y = div(i, 6) * 5 + 3
    {x, y}
  end

  defp convert(i) do
    (i - 1) * @width + 2 * @width
  end
end
