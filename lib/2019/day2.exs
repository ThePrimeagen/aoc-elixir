{:ok, contents} = File.read("./day2.input")

defmodule IntComp do
  defstruct items: {}, idx: 0
  @add 1
  @mul 2

  def op_to_string(@add), do: "add"
  def op_to_string(@mul), do: "mul"

  def createComp(items) do
    %IntComp{items: List.to_tuple(items), idx: 0}
  end

  # required for D2P2
  def update_initial_memory(comp, noun, verb) do
    # required for D2P1
    comp = update_value(comp, 1, noun)
    update_value(comp, 2, verb)
  end

  def update_all(struct, new_idx, value_idx, new_value) do
    # do i need to do a struct | to ensure that we have the same memory?
    %IntComp{idx: new_idx, items: put_elem(struct.items, value_idx, new_value)}
  end

  def update_value(struct, value_idx, new_value) do
    # do i need to do a struct | to ensure that we have the same memory?
    %IntComp{struct | items: put_elem(struct.items, value_idx, new_value)}
  end

  def prog_value(struct) do
    elem(struct.items, 0)
  end

  defp ivalue(struct, idx) do
    elem(struct.items, elem(struct.items, idx))
  end

  defp get_op(struct) do
    elem(struct.items, struct.idx)
  end

  def run(struct) when elem(struct.items, struct.idx) == 99 do
    struct
  end

  def run(struct) when elem(struct.items, struct.idx) != 99 do
    idx = struct.idx

    struct = case get_op(struct) do
      @add ->
        add = ivalue(struct, idx + 1) + ivalue(struct, idx + 2)
        update_all(struct, idx + 4, elem(struct.items, idx + 3), add)
      @mul ->
        mul = ivalue(struct, idx + 1) * ivalue(struct, idx + 2)
        update_all(struct, idx + 4, elem(struct.items, idx + 3), mul)
    end
    run(struct)
  end
end

defimpl String.Chars, for: IntComp do
  def to_string(%IntComp{idx: idx, items: items}) do
    val = elem(items, idx)
    items = for i <- idx..idx + 4, i < tuple_size(items), do: elem(items, i)
    str_items = Enum.join(items, ", ")
    "IntComp: idx: #{IntComp.op_to_string(val)}(#{idx}) - items: #{str_items}"
  end
end

defmodule IntCompRuns do
  def search(comp, value) do
    0..100
    |> Stream.flat_map(fn i -> Stream.map(0..100, &({i, &1})) end)
    |> Enum.find(fn {i, j} -> inner_search?(comp, i, j, value) end)
  end

  defp inner_search?(comp, noun, verb, needle) do
    comp = IntComp.update_initial_memory(comp, noun, verb)
    comp = IntComp.run(comp)
    IO.puts("run: #{noun} - #{verb} - res = #{IntComp.prog_value(comp)} == #{needle}")
    needle == IntComp.prog_value(comp)
  end
end

items = String.split(contents, ",")
|> Enum.map(&(String.to_integer(String.trim(&1))))

comp = IntComp.createComp(items)

IntCompRuns.search(comp, 19690720)
IO.inspect(comp)

