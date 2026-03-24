defmodule Pento.Game.PointTest do
  use ExUnit.Case, async: true

  alias Pento.Game.Point

  describe "new/2" do
    test "creates a point tuple" do
      assert Point.new(2, 3) == {2, 3}
    end
  end

  describe "move/2" do
    test "moves a point by the given offsets" do
      assert Point.move({2, 3}, {1, -1}) == {3, 2}
    end
  end

  describe "transpose/1" do
    test "swaps x and y" do
      assert Point.transpose({2, 3}) == {3, 2}
    end
  end

  describe "flip/1" do
    test "flips a point vertically within the 5x5 grid" do
      assert Point.flip({1, 1}) == {1, 5}
      assert Point.flip({3, 4}) == {3, 2}
    end
  end

  describe "reflect/1" do
    test "reflects a point horizontally within the 5x5 grid" do
      assert Point.reflect({1, 1}) == {5, 1}
      assert Point.reflect({4, 3}) == {2, 3}
    end
  end

  describe "rotate/2" do
    test "rotates a point 0 degrees" do
      assert Point.rotate({3, 2}, 0) == {3, 2}
    end

    test "rotates a point 90 degrees" do
      assert Point.rotate({4, 3}, 90) == {3, 2}
    end

    test "rotates a point 180 degrees" do
      assert Point.rotate({3, 2}, 180) == {3, 4}
    end

    test "rotates a point 270 degrees" do
      assert Point.rotate({3, 2}, 270) == {4, 3}
    end
  end

  describe "center/1" do
    test "offsets a point by {-3, -3}" do
      assert Point.center({5, 5}) == {2, 2}
    end
  end

  describe "maybe_reflect/2" do
    test "reflects when true" do
      assert Point.maybe_reflect({4, 2}, true) == {2, 2}
    end

    test "returns the same point when false" do
      assert Point.maybe_reflect({4, 2}, false) == {4, 2}
    end
  end

  describe "prepare/4" do
    test "prepares a point for rendering" do
      assert Point.prepare({3, 2}, 90, true, {5, 5}) == {6, 5}
    end
  end
end
