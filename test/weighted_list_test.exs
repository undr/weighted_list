defmodule WeightedListTest do
  use ExUnit.Case
  doctest WeightedList

  test "&new/1" do
    assert {:ok, ref} = WeightedList.new(%{"0.1" => 10, "0.2" => 7, "0.3" => 5, "0.4" => 2, "0.5" => 1})
    assert ["0.1", "0.2", "0.3", "0.4", "0.5"] = WeightedList.values(ref)
    assert [0, 0, 2, 0, 1] = WeightedList.aliases(ref)
    assert [1.0, 0.4000000059604645, 1.0, 0.6000000238418579, 0.800000011920929] = WeightedList.probs(ref)

    assert {:error, :badweight} = WeightedList.new(%{"0.1" => 10, "0.2" => 7, "0.3" => 5, "0.4" => "2", "0.5" => 1})

    assert {:ok, ref} = WeightedList.new([{"0.1", 10}, {"0.2", 7}, {"0.3", 5}, {"0.4", 2}, {"0.5", 1}])
    assert ["0.1", "0.2", "0.3", "0.4", "0.5"] = WeightedList.values(ref)
    assert [0, 0, 2, 0, 1] = WeightedList.aliases(ref)
    assert [1.0, 0.4000000059604645, 1.0, 0.6000000238418579, 0.800000011920929] = WeightedList.probs(ref)

    assert {:error, :badweight} = WeightedList.new([{"0.1", 10}, {"0.2", 7}, {"0.3", 5}, {"0.4", "2"}, {"0.5", 1}])
  end

  test "&new/2" do
    assert {:ok, ref} = WeightedList.new(["0.1", "0.2", "0.3", "0.4", "0.5"], [10, 7, 5, 2, 1])
    assert ["0.1", "0.2", "0.3", "0.4", "0.5"] = WeightedList.values(ref)
    assert [0, 0, 2, 0, 1] = WeightedList.aliases(ref)
    assert [1.0, 0.4000000059604645, 1.0, 0.6000000238418579, 0.800000011920929] = WeightedList.probs(ref)

    assert {:error, :badweight} = WeightedList.new(["0.1", "0.2", "0.3", "0.4", "0.5"], [10, 7, 5, "2", 1])
    assert {:error, :badarg} = WeightedList.new(["0.1", "0.2", "0.3", "0.4"], [10, 7, 5, 2, 1])
    assert {:error, :badarg} = WeightedList.new(:not_a_list, [10, 7, 5, 2, 1])
    assert {:error, :badarg} = WeightedList.new(["0.1", "0.2", "0.3", "0.4", "0.5"], :not_a_list)
    assert {:error, :badarg} = WeightedList.new(:not_a_list, :not_a_list)
  end

  test "&get/3" do
    assert {:ok, ref} = WeightedList.new(%{"0.1" => 10, "0.2" => 7, "0.3" => 5, "0.4" => 2, "0.5" => 1})
    size = WeightedList.size(ref)

    assert {:ok, "0.2"} = WeightedList.get(ref, 1, 0.5)
    assert {:ok, "0.1"} = WeightedList.get(ref, 1, 0.3)
    assert {:ok, "0.2"} = WeightedList.get(ref, 4, 0.7)
    assert {:ok, "0.5"} = WeightedList.get(ref, 4, 0.81)

    sample1 =
      1..25000
      |> Enum.map(fn _ -> WeightedList.get(ref, :rand.uniform(size) - 1, :rand.uniform()) |> elem(1) end)
      |> Enum.reduce(%{}, fn v, acc -> Map.update(acc,v, 1, fn ex -> ex + 1 end) end)
      |> Enum.map(fn {k,v} -> {k, round(v/100)} end)
      |> Map.new()

    sample2 =
      1..25000
      |> Enum.map(fn _ -> WeightedList.get(ref, :rand.uniform(size) - 1, :rand.uniform()) |> elem(1) end)
      |> Enum.reduce(%{}, fn v, acc -> Map.update(acc,v, 1, fn ex -> ex + 1 end) end)
      |> Enum.map(fn {k,v} -> {k, round(v/100)} end)
      |> Map.new()

    Enum.each(sample1, fn {k, v} ->
      assert_in_delta v, Map.get(sample2, k), 3
    end)
  end

  test "&index/3" do
    assert {:ok, ref} = WeightedList.new(%{"0.1" => 10, "0.2" => 7, "0.3" => 5, "0.4" => 2, "0.5" => 1})
    size = WeightedList.size(ref)

    assert {:ok, 1} = WeightedList.index(ref, 1, 0.5)
    assert {:ok, 0} = WeightedList.index(ref, 1, 0.3)
    assert {:ok, 1} = WeightedList.index(ref, 4, 0.7)
    assert {:ok, 4} = WeightedList.index(ref, 4, 0.81)

    sample1 =
      1..25000
      |> Enum.map(fn _ -> WeightedList.index(ref, :rand.uniform(size) - 1, :rand.uniform()) |> elem(1) end)
      |> Enum.reduce(%{}, fn v, acc -> Map.update(acc,v, 1, fn ex -> ex + 1 end) end)
      |> Enum.map(fn {k,v} -> {k, round(v/100)} end)
      |> Map.new()

    sample2 =
      1..25000
      |> Enum.map(fn _ -> WeightedList.index(ref, :rand.uniform(size) - 1, :rand.uniform()) |> elem(1) end)
      |> Enum.reduce(%{}, fn v, acc -> Map.update(acc,v, 1, fn ex -> ex + 1 end) end)
      |> Enum.map(fn {k,v} -> {k, round(v/100)} end)
      |> Map.new()

    Enum.each(sample1, fn {k, v} ->
      assert_in_delta v, Map.get(sample2, k), 3
    end)
  end
end
