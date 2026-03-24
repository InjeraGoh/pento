defmodule Pento.Game.ShapeTest do
  use ExUnit.Case, async: true

  alias Pento.Game.Shape

  describe "new/4" do
    test "builds a shape with the correct name, color, and points" do
      shape = Shape.new(:p, 90, true, {5, 5})

      assert shape.name == :p
      assert shape.color == :orange
      assert shape.points == [{6, 5}, {6, 4}, {5, 5}, {5, 4}, {4, 5}]
    end
  end
end
