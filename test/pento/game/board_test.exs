defmodule Pento.Game.BoardTest do
  use ExUnit.Case, async: true

  alias Pento.Game.Board
  alias Pento.Game.Pentomino
  alias Pento.Game.Shape

  describe "puzzles/0" do
    test "puzzles/0 returns supported board names" do
      assert Board.puzzles() == [:tiny, :small, :ball, :donut, :default, :wide, :widest, :medium]
    end
  end

  describe "new/1" do
    test "builds a tiny board" do
      board = Board.new(:tiny)

      assert board.active_pento == nil
      assert board.completed_pentos == []
      assert board.palette == [:u, :v, :p]
      assert length(board.points) == 15
      assert {1, 1} in board.points
      assert {5, 3} in board.points
    end

    test "builds a default board" do
      board = Board.new(:default)

      assert length(board.points) == 60
      assert {1, 1} in board.points
      assert {10, 6} in board.points
    end
  end

  describe "to_shape/1" do
    test "converts a board into a board shape" do
      board = Board.new(:tiny)
      shape = Board.to_shape(board)

      assert %Shape{} = shape
      assert shape.name == :board
      assert shape.color == :purple
      assert length(shape.points) == 15
    end
  end

  describe "to_shapes/1" do
    test "returns only the board shape when no pentos are active or completed" do
      board = Board.new(:tiny)
      shapes = Board.to_shapes(board)

      assert length(shapes) == 1
      assert hd(shapes).name == :board
    end

    test "returns board, completed pentos, and active pento in render order" do
      completed = Pentomino.new(name: :u)
      active = Pentomino.new(name: :p)

      board = %Board{
        Board.new(:tiny)
        | completed_pentos: [completed],
          active_pento: active
      }

      shapes = Board.to_shapes(board)

      assert Enum.map(shapes, & &1.name) == [:board, :u, :p]
    end
  end

  describe "active?/2" do
    test "returns true when given the active pento name as an atom" do
      board = %Board{Board.new(:tiny) | active_pento: Pentomino.new(name: :p)}

      assert Board.active?(board, :p)
    end

    test "returns true when given the active pento name as a string" do
      board = %Board{Board.new(:tiny) | active_pento: Pentomino.new(name: :p)}

      assert Board.active?(board, "p")
    end

    test "returns false for a non-active pento" do
      board = %Board{Board.new(:tiny) | active_pento: Pentomino.new(name: :p)}

      refute Board.active?(board, :u)
    end
  end

  describe "skewed_rect puzzle" do
    test "builds a skewed board" do
      board = Board.new(:skewed)

      assert length(board.points) == 60
      assert {1, 1} in board.points
      assert {10, 1} in board.points
      assert {2, 2} in board.points
      assert {11, 2} in board.points
      assert {6, 6} in board.points
      assert {15, 6} in board.points
    end
  end
end
