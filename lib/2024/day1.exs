list =
  File.stream!("./day1.input", :line)
  |> Stream.map(&String.trim/1)
  |> Stream.filter(&(byte_size(&1) > 0))
  |> Stream.map(&String.split(&1, " "))
  |> Enum.to_list()

{left, right} =
  list
  |> Enum.reduce({[], []}, fn value, {list1, list2} ->
    a = String.to_integer(Enum.at(value, 0))
    b = String.to_integer(Enum.at(value, 3))
    {[a | list1], [b | list2]}
  end)

freq = Enum.frequencies(right)

left
|> Enum.reduce(0, fn value, acc ->
  v = Map.get(freq, value, 0)
  acc + value * v
end)
|> IO.inspect()
