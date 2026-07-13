defmodule A do
  @moduledoc "It's doc"

  # This is a comment

  @doc """
  Hello

      iex> A.hello()
      :world
  """
  def hello(), do: :world
  def hello2(), do: "world"
end
