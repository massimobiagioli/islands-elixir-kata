defmodule IslandEngine.Board do
  @moduledoc """
  Documentation for `Board`.
  """
  alias IslandEngine.{Coordinate, Island}

  @doc """
  Create new board

  ## Examples

      iex> alias IslandEngine.Board
      iex> Board.new()
      %{}

  """
  def new(), do: %{}

  @doc """
  Position island on board

  ## Examples

      iex> alias IslandEngine.{Coordinate, Board, Island}
      iex> board = Board.new()
      iex> {:ok, square_coordinate} = Coordinate.new(1, 1)
      iex> {:ok, square} = Island.new(:square, square_coordinate)
      iex> board = Board.position_island(board, :square, square)
      iex> board.square.coordinates
      Enum.into([%IslandEngine.Coordinate{col: 1, row: 1}, %IslandEngine.Coordinate{col: 1, row: 2}, %IslandEngine.Coordinate{col: 2, row: 1}, %IslandEngine.Coordinate{col: 2, row: 2}], MapSet.new())
      iex> {:ok, dot_coordinate} = Coordinate.new(2, 2)
      iex> {:ok, dot} = Island.new(:dot, dot_coordinate)
      iex> Board.position_island(board, :dot, dot)
      {:error, :overlapping_island}
      iex> {:ok, new_dot_coordinate} = Coordinate.new(3, 3)
      iex> {:ok, dot} = Island.new(:dot, new_dot_coordinate)
      iex> board = Board.position_island(board, :dot, dot)
      iex> board.dot.coordinates
      Enum.into([%IslandEngine.Coordinate{col: 3, row: 3}], MapSet.new())

  """
  def position_island(board, key, %Island{} = island) do
    case overlaps_existing_island?(board, key, island) do
      true -> {:error, :overlapping_island}
      false -> Map.put(board, key, island)
    end
  end

  defp overlaps_existing_island?(board, new_key, new_island) do
    Enum.any?(board, fn {key, island} ->
      key != new_key and Island.overlaps?(island, new_island)
    end)
  end

  def all_islands_positioned?(board), do:
    Enum.all?(Island.types, &(Map.has_key?(board, &1)))

  @doc """
  Guess ...

  ## Examples

      iex> alias IslandEngine.{Coordinate, Board, Island}
      iex> board = Board.new()
      iex> {:ok, square_coordinate} = Coordinate.new(1, 1)
      iex> {:ok, square} = Island.new(:square, square_coordinate)
      iex> board = Board.position_island(board, :square, square)
      iex> {:ok, dot_coordinate} = Coordinate.new(3, 3)
      iex> {:ok, dot} = Island.new(:dot, dot_coordinate)
      iex> board = Board.position_island(board, :dot, dot)
      iex> {:ok, guess_coordinate} = Coordinate.new(10, 10)
      iex> {:miss, :none, :no_win, _board} = Board.guess(board, guess_coordinate)
      iex> {:ok, hit_coordinate} = Coordinate.new(1, 1)
      iex> {:hit, :none, :no_win, _board} = Board.guess(board, hit_coordinate)

  """
  def guess(board, %Coordinate{} = coordinate) do
    board
    |> check_all_islands(coordinate)
    |> guess_response(board)
  end

  defp check_all_islands(board, coordinate) do
    Enum.find_value(board, :miss, fn {key, island} ->
      case Island.guess(island, coordinate) do
        {:hit, island} -> {key, island}
        :miss -> false
      end
    end)
  end

  defp guess_response({key, island}, board) do
    board = %{board | key => island}
    {:hit, forest_check(board, key), win_check(board), board}
  end

  defp guess_response(:miss, board), do: {:miss, :none, :no_win, board}

  defp forest_check(board, key) do
    case forested?(board, key) do
      true -> key
      false -> :none
    end
  end

  defp forested?(board, key) do
    board
    |> Map.fetch!(key)
    |> Island.forested?()
  end

  defp win_check(board) do
    case all_forested?(board) do
      true -> :win
      false -> :no_win
    end
  end

  defp all_forested?(board), do:
    Enum.all?(board, fn {_key, island} -> Island.forested?(island) end)

end
