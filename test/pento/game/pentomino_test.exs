defmodule Pento.Game.PentominoTest do
  use ExUnit.Case, async: true

  alias Pento.Game.Pentomino
  alias Pento.Game.Shape

  describe "new/1" do
    test "creates a pentomino with defaults" do
      pento = Pentomino.new()

      assert pento.name == :i
      assert pento.rotation == 0
      assert pento.reflected == false
      assert pento.location == {8, 8}
    end

    test "creates a pentomino with provided fields" do
      pento = Pentomino.new(name: :p, rotation: 270, reflected: true, location: {11, 5})

      assert pento.name == :p
      assert pento.rotation == 270
      assert pento.reflected == true
      assert pento.location == {11, 5}
    end
  end

  describe "rotate/1" do
    test "rotates clockwise by 90 degrees" do
      pento = Pentomino.new(rotation: 0)

      assert Pentomino.rotate(pento).rotation == 90
    end

    test "wraps from 270 back to 0" do
      pento = Pentomino.new(rotation: 270)

      assert Pentomino.rotate(pento).rotation == 0
    end
  end

  describe "flip/1" do
    test "toggles reflected from false to true" do
      pento = Pentomino.new(reflected: false)

      assert Pentomino.flip(pento).reflected == true
    end

    test "toggles reflected from true to false" do
      pento = Pentomino.new(reflected: true)

      assert Pentomino.flip(pento).reflected == false
    end
  end

  describe "movement reducers" do
    test "moves up" do
      pento = Pentomino.new(location: {8, 8})

      assert Pentomino.up(pento).location == {8, 7}
    end

    test "moves down" do
      pento = Pentomino.new(location: {8, 8})

      assert Pentomino.down(pento).location == {8, 9}
    end

    test "moves left" do
      pento = Pentomino.new(location: {8, 8})

      assert Pentomino.left(pento).location == {7, 8}
    end

    test "moves right" do
      pento = Pentomino.new(location: {8, 8})

      assert Pentomino.right(pento).location == {9, 8}
    end
  end

  describe "to_shape/1" do
    test "converts pentomino state into a shape" do
      pento =
        Pentomino.new(name: :i)
        |> Pentomino.rotate()
        |> Pentomino.rotate()
        |> Pentomino.down()

      shape = Pentomino.to_shape(pento)

      assert %Shape{} = shape
      assert shape.name == :i
      assert shape.color == :dark_green
      assert shape.points == [{8, 11}, {8, 10}, {8, 9}, {8, 8}, {8, 7}]
    end
  end

  describe "rotate/2" do
    test "rotates clockwise when explicitly requested" do
      pento = Pentomino.new(rotation: 0)

      assert Pentomino.rotate(pento, :clockwise).rotation == 90
    end

    test "rotates counterclockwise" do
      pento = Pentomino.new(rotation: 0)

      assert Pentomino.rotate(pento, :counterclockwise).rotation == 270
    end

    test "rotates counterclockwise from 90 to 0" do
      pento = Pentomino.new(rotation: 90)

      assert Pentomino.rotate(pento, :counterclockwise).rotation == 0
    end
end
end
