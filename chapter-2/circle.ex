defmodule Circle do
  @moduledoc """
  A module for calculating the area of a circle.
  """
  @pi 3.14159

  @doc """
  Calculates the area of a circle.
  """
  @spec area(number) :: number
  def area(radius) do
    @pi * radius * radius
  end

  @doc """
  Calculates the circumference of a circle.
  """
  @spec circumference(number) :: number
  def circumference(radius) do
    2 * @pi * radius
  end
end
