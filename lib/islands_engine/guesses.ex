defmodule IslandEngine.Guesses do
  @moduledoc """
  Documentation for `Guesses`.
  """
  alias IslandEngine.{Guesses, Coordinate}

  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  @doc """
  Create new guesses.

  ## Examples

      iex> alias IslandEngine.Guesses
      iex> Guesses.new()
      %IslandEngine.Guesses{hits: %MapSet{}, misses: %MapSet{}}

  """
  def new(), do: %Guesses{hits: MapSet.new(), misses: MapSet.new()}

  @doc """
  Add coordinates to hits map.

  ## Examples

      iex> alias IslandEngine.{Coordinate, Guesses}
      iex> guesses = Guesses.new()
      iex> {:ok, coordinate_hit} = Coordinate.new(1, 1)
      iex> Guesses.add(guesses, :hit, coordinate_hit)
      %IslandEngine.Guesses{hits: Enum.into([%IslandEngine.Coordinate{col: 1, row: 1}], MapSet.new()), misses: %MapSet{}}

      iex> alias IslandEngine.{Coordinate, Guesses}
      iex> guesses = Guesses.new()
      iex> {:ok, coordinate_misses} = Coordinate.new(2, 2)
      iex> Guesses.add(guesses, :misses, coordinate_misses)
      %IslandEngine.Guesses{hits: %MapSet{}, misses: Enum.into([%IslandEngine.Coordinate{col: 2, row: 2}], MapSet.new())}

  """
  def add(%Guesses{} = guesses, :hit, %Coordinate{} = coordinate),
    do: update_in(guesses.hits, &MapSet.put(&1, coordinate))

  def add(%Guesses{} = guesses, :misses, %Coordinate{} = coordinate),
    do: update_in(guesses.misses, &MapSet.put(&1, coordinate))
end
