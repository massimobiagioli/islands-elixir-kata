defmodule IslandEngine.Island do
  @moduledoc """
  Documentation for `Island`.
  """
  alias IslandEngine.{Coordinate, Island}

  @enforce_keys [:coordinates, :hit_coordinates]
  defstruct [:coordinates, :hit_coordinates]

  @doc """
  Get all supported types

  ## Examples

      iex> alias IslandEngine.Island
      iex> Island.types()
      [:atoll, :dot, :l_shape, :s_shape, :square]

  """
  def types(), do: [:atoll, :dot, :l_shape, :s_shape, :square]

  @doc """
  Create new island

  ## Examples

      iex> alias IslandEngine.{Coordinate, Island}
      iex> {:ok, coordinate} = Coordinate.new(1, 1)
      iex> {:ok, atoll_island} = Island.new(:atoll, coordinate)
      iex> atoll_island.coordinates
      Enum.into([%IslandEngine.Coordinate{col: 1, row: 1}, %IslandEngine.Coordinate{col: 1, row: 3}, %IslandEngine.Coordinate{col: 2, row: 1}, %IslandEngine.Coordinate{col: 2, row: 2}, %IslandEngine.Coordinate{col: 2, row: 3}], MapSet.new())

      iex> alias IslandEngine.{Coordinate, Island}
      iex> {:ok, coordinate} = Coordinate.new(1, 1)
      iex> {:ok, dot_island} = Island.new(:dot, coordinate)
      iex> dot_island.coordinates
      Enum.into([%IslandEngine.Coordinate{col: 1, row: 1}], MapSet.new())

      iex> alias IslandEngine.{Coordinate, Island}
      iex> {:ok, coordinate} = Coordinate.new(1, 1)
      iex> {:ok, square_island} = Island.new(:square, coordinate)
      iex> square_island.coordinates
      Enum.into([%IslandEngine.Coordinate{col: 1, row: 1}, %IslandEngine.Coordinate{col: 1, row: 2}, %IslandEngine.Coordinate{col: 2, row: 1}, %IslandEngine.Coordinate{col: 2, row: 2}], MapSet.new())

      iex> alias IslandEngine.{Coordinate, Island}
      iex> {:ok, coordinate} = Coordinate.new(1, 1)
      iex> {:ok, l_shape_island} = Island.new(:l_shape, coordinate)
      iex> l_shape_island.coordinates
      Enum.into([%IslandEngine.Coordinate{col: 1, row: 1}, %IslandEngine.Coordinate{col: 1, row: 2}, %IslandEngine.Coordinate{col: 1, row: 3}, %IslandEngine.Coordinate{col: 2, row: 3}], MapSet.new())

      iex> alias IslandEngine.{Coordinate, Island}
      iex> {:ok, coordinate} = Coordinate.new(1, 1)
      iex> {:ok, s_shape_island} = Island.new(:s_shape, coordinate)
      iex> s_shape_island.coordinates
      Enum.into([%IslandEngine.Coordinate{col: 1, row: 2}, %IslandEngine.Coordinate{col: 2, row: 1}, %IslandEngine.Coordinate{col: 2, row: 2}, %IslandEngine.Coordinate{col: 3, row: 1}], MapSet.new())

      iex> alias IslandEngine.{Coordinate, Island}
      iex> {:ok, coordinate} = Coordinate.new(1, 1)
      iex> Island.new(:bad_type, coordinate)
      {:error, :invalid_island_type}

  """
  def new(type, %Coordinate{} = upper_left) do
    with [_ | _] = offsets <- offsets(type),
         %MapSet{} = coordinates <- add_coordinates(offsets, upper_left) do
      {:ok, %Island{coordinates: coordinates, hit_coordinates: MapSet.new()}}
    else
      error -> error
    end
  end

  @doc """
  Check if two islands are overlapped

  ## Examples

      iex> alias IslandEngine.{Coordinate, Island}
      iex> {:ok, coordinate} = Coordinate.new(1, 1)
      iex> {:ok, first_island} = Island.new(:square, coordinate)
      iex> {:ok, second_island} = Island.new(:square, coordinate)
      iex> Island.overlaps?(first_island, second_island)
      true

      iex> alias IslandEngine.{Coordinate, Island}
      iex> {:ok, first_coordinate} = Coordinate.new(1, 1)
      iex> {:ok, first_island} = Island.new(:square, first_coordinate)
      iex> {:ok, second_coordinate} = Coordinate.new(1, 2)
      iex> {:ok, second_island} = Island.new(:square, second_coordinate)
      iex> Island.overlaps?(first_island, second_island)
      true

      iex> alias IslandEngine.{Coordinate, Island}
      iex> {:ok, first_coordinate} = Coordinate.new(1, 1)
      iex> {:ok, first_island} = Island.new(:square, first_coordinate)
      iex> {:ok, second_coordinate} = Coordinate.new(5, 5)
      iex> {:ok, second_island} = Island.new(:square, second_coordinate)
      iex> Island.overlaps?(first_island, second_island)
      false

  """
  def overlaps?(existing_island, new_island),
    do: not MapSet.disjoint?(existing_island.coordinates, new_island.coordinates)

  @doc """
  Check if two islands are overlapped

  ## Examples

      iex> alias IslandEngine.{Coordinate, Island}
      iex> {:ok, upper_left} = Coordinate.new(1, 1)
      iex> {:ok, island} = Island.new(:square, upper_left)
      iex> {:ok, guess_coordinate} = Coordinate.new(2, 2)
      iex> {:hit, island} = Island.guess(island, guess_coordinate)
      iex> island.hit_coordinates
      Enum.into([%IslandEngine.Coordinate{col: 2, row: 2}], MapSet.new())

      iex> alias IslandEngine.{Coordinate, Island}
      iex> {:ok, upper_left} = Coordinate.new(1, 1)
      iex> {:ok, island} = Island.new(:square, upper_left)
      iex> {:ok, guess_coordinate} = Coordinate.new(5, 5)
      iex> Island.guess(island, guess_coordinate)
      :miss

  """
  def guess(island, coordinate) do
    case MapSet.member?(island.coordinates, coordinate) do
      true ->
        hit_coordinates = MapSet.put(island.hit_coordinates, coordinate)
        {:hit, %{island | hit_coordinates: hit_coordinates}}

      false ->
        :miss
    end
  end

  def forested?(island), do: MapSet.equal?(island.coordinates, island.hits_coordinates)

  defp offsets(:square), do: [{0, 0}, {0, 1}, {1, 0}, {1, 1}]

  defp offsets(:atoll), do: [{0, 0}, {0, 1}, {1, 1}, {2, 0}, {2, 1}]

  defp offsets(:dot), do: [{0, 0}]

  defp offsets(:l_shape), do: [{0, 0}, {1, 0}, {2, 0}, {2, 1}]

  defp offsets(:s_shape), do: [{0, 1}, {0, 2}, {1, 0}, {1, 1}]

  defp offsets(_), do: {:error, :invalid_island_type}

  defp add_coordinates(offsets, upper_left) do
    Enum.reduce_while(offsets, MapSet.new(), fn offset, acc ->
      add_coordinate(acc, upper_left, offset)
    end)
  end

  defp add_coordinate(coordinates, %Coordinate{row: row, col: col}, {row_offset, col_offset}) do
    case Coordinate.new(row + row_offset, col + col_offset) do
      {:ok, coordinate} -> {:cont, MapSet.put(coordinates, coordinate)}
      {:error, :invalid_coordinate} -> {:halt, {:error, :invalid_coordinate}}
    end
  end
end
