defmodule IslandEngine.Coordinate do
  @moduledoc """
  Documentation for `Coordinate`.
  """
  alias __MODULE__

  @enforce_keys [:row, :col]
  defstruct [:row, :col]

  @board_range 1..10

  @doc """
  Create new coordinate

  ## Examples

      iex> alias IslandEngine.Coordinate
      iex> Coordinate.new(1, 1)
      {:ok, %IslandEngine.Coordinate{col: 1, row: 1}}

      iex> alias IslandEngine.Coordinate
      iex> Coordinate.new(1, 11)
      {:error, :invalid_coordinate}

  """
  def new(row, col) when row in @board_range and col in @board_range,
    do: {:ok, %Coordinate{row: row, col: col}}

  def new(_row, _col), do: {:error, :invalid_coordinate}
end
