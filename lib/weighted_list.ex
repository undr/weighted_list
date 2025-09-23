defmodule WeightedList do
  alias WeightedList.Native

  @moduledoc """
  Documentation for `WeightedList`.
  """

  @spec new(map()) :: {:ok, reference()} | {:error, atom()}
  def new(map) when is_map(map) do
    map
    |> Map.to_list()
    |> new()
  end

  @spec new([{term(), non_neg_integer()}, ...]) :: {:ok, reference()} | {:error, atom()}
  def new(list) when is_list(list) do
    values = Enum.map(list, &elem(&1, 0))
    weights = Enum.map(list, &elem(&1, 1))

    new(values, weights)
  end

  @spec new([term(), ...], [non_neg_integer(), ...]) :: {:ok, reference()} | {:error, atom()}
  def new(values, weights) do
    setup(values, weights)
  rescue
    ArgumentError -> {:error, :badweight}
  end

  @spec get(reference(), non_neg_integer(), float()) :: float()
  def get(ref, idx, rng) do
    Native.get(ref, idx, rng)
  end

  @spec index(reference(), non_neg_integer(), float()) :: float()
  def index(ref, idx, rng) do
    Native.index(ref, idx, rng)
  end

  @spec values(reference()) :: list()
  def values(ref) do
    Native.values(ref)
  end

  @spec aliases(reference()) :: list()
  def aliases(ref) do
    Native.aliases(ref)
  end

  @spec probs(reference()) :: list()
  def probs(ref) do
    Native.probs(ref)
  end

  @spec size(reference()) :: non_neg_integer()
  def size(ref) do
    Native.size(ref)
  end

  defp setup(values, weights) when is_list(values) and is_list(weights) and length(values) == length(weights) do
    {:ok, Native.setup(values, weights)}
  end

  defp setup(_values, _weights) do
    {:error, :badarg}
  end
end
