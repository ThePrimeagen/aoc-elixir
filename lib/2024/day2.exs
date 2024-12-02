defmodule AOC24D2 do
  def is_safe_lesser(list, count) when count > 1 do
    false
  end

  def is_safe_lesser(list, count) do
    IO.inspect(list, label: "is_lesser")

    case list do
      [a, b | tail] when (b - a) in 1..3 ->
        is_safe_lesser([b | tail], count)

      [a, b | tail] when (b - a) not in 1..3 ->
        is_safe_lesser([a | tail], count + 1)

      [] ->
        IO.inspect(list, label: "empty")
        true

      [_] ->
        IO.inspect(list, label: "one el")
        true

      _ ->
        IO.inspect(list, label: "unknown")
        false
    end
  end

  def is_safe_greater(list, count) when count > 1 do
    false
  end

  def is_safe_greater(list, count) do
    IO.inspect(list, label: "is_greater")

    case list do
      [] ->
        true

      [_] ->
        true

      [a, b | tail] when (a - b) in 1..3 ->
        is_safe_greater([b | tail], count)

      [a, b | tail] when (a - b) not in 1..3 ->
        is_safe_greater([a | tail], count + 1)

      _ ->
        false
    end
  end

  def is_safe(list) do
    IO.inspect(list, label: "is_safe")

    case list do
      [a, b | tail] ->
        is_safe_lesser([a, b | tail], 0) or is_safe_lesser([b | tail], 1) or
          is_safe_greater([a, b | tail], 0) or is_safe_greater([b | tail], 1)

      [] ->
        true

      [_] ->
        true

      _ ->
        false
    end
  end
end

list =
  File.stream!("./day2.input", :line)
  |> Stream.map(&String.trim/1)
  |> Stream.filter(&(byte_size(&1) > 0))
  |> Stream.map(&String.split(&1, " "))
  |> Stream.map(fn list -> Enum.map(list, &String.to_integer/1) end)
  |> Stream.filter(&AOC24D2.is_safe(&1))
  |> Stream.filter(fn
    [] ->
      IO.puts("hello its empty!")
      false

    _ ->
      IO.puts("hello its has elements!")
      true
  end)
  |> Enum.to_list()

IO.inspect(list, charlists: :as_lists, label: "length")
IO.inspect(Kernel.length(list), charlists: :as_lists, label: "length")
