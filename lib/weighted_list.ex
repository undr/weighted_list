defmodule WeightedList do
  alias WeightedList.Native

  @moduledoc """
  Documentation for `WeightedList`.
  """

  def new(map) when is_map(map) do
    map
    |> Map.to_list()
    |> new()
  end

  def new(list) when is_list(list) do
    values = Enum.map(list, &elem(&1, 0))
    weights = Enum.map(list, &elem(&1, 1))

    new(values, weights)
  end

  def new(values, weights) when is_list(values) and is_list(weights) do
    {:ok, Native.setup(values, weights)}
  end

  @spec get(reference(), non_neg_integer(), float()) :: float()
  def get(wl, idx, rng) do
    Native.get(wl, idx, rng)
  end

  @spec index(reference(), non_neg_integer(), float()) :: float()
  def index(wl, idx, rng) do
    Native.index(wl, idx, rng)
  end

  @spec values(reference()) :: list()
  def values(wl) do
    Native.values(wl)
  end

  @spec aliases(reference()) :: list()
  def aliases(wl) do
    Native.aliases(wl)
  end

  @spec probs(reference()) :: list()
  def probs(wl) do
    Native.probs(wl)
  end

  @spec size(reference()) :: non_neg_integer()
  def size(wl) do
    Native.size(wl)
  end
end
