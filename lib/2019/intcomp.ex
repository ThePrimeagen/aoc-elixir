defmodule IntComp do
  defstruct debug: false, last_output: 0, input: 0, items: {}, idx: 0

  @exit 99
  @add 1
  @mul 2
  @input 3
  @output 4
  # is jump-if-true: if the first parameter is non-zero, it sets the
  # instruction pointer to the value from the second parameter. Otherwise, it
  # does nothing.
  @jump_if_true 5
  #is jump-if-false: if the first parameter is zero, it sets the instruction
  #pointer to the value from the second parameter. Otherwise, it does nothing.
  @jump_if_false 6
  #is less than: if the first parameter is less than the second parameter, it
  #stores 1 in the position given by the third parameter. Otherwise, it stores
  #0.
  @less_than 7
  #is equals: if the first parameter is equal to the second parameter,
  #it stores 1 in the position given by the third parameter. Otherwise, it
  #stores 0.
  @equal 8

  @parameter 0
  @immediate 1

  @prog_counter Map.new([
    {@add, 4},
    {@mul, 4},
    {@input, 2},
    {@output, 2},
    {@less_than, 4},
    {@equal, 4},
  ])

  @arg_count Map.new([
    {@add, 2},
    {@mul, 2},
    {@input, 0},
    {@output, 1},
    {@less_than, 2},
    {@equal, 2},
    {@jump_if_true, 1},
    {@jump_if_false, 1},
  ])


  def exit, do: @exit
  def op_to_string(@add), do: "add"
  def op_to_string(@mul), do: "mul"
  def op_to_string(@input), do: "input"
  def op_to_string(@output), do: "output"
  def op_to_string(@equal), do: "equal"
  def op_to_string(@less_than), do: "less_than"
  def op_to_string(@jump_if_false), do: "jump_if_false"
  def op_to_string(@jump_if_true), do: "jump_if_true"
  def op_to_string(@exit), do: "exit"

  def computer(items, input) do
    %IntComp{input: input, items: List.to_tuple(items)}
  end

  def debug_computer(items, input) do
    %IntComp{debug: true, input: input, items: List.to_tuple(items)}
  end

  def update_value(struct, value_idx, new_value) do
    %IntComp{struct | items: put_elem(struct.items, value_idx, new_value)}
  end

  def update_last_output(struct, output) do
    %IntComp{struct | last_output: output}
  end

  def update_program_counter(struct, jump) do
    %IntComp{struct | idx: struct.idx + jump}
  end

  def update_program_counter_to(struct, new_idx) do
    %IntComp{struct | idx: new_idx}
  end

  def prog_value(struct) do
    elem(struct.items, 0)
  end

  defp ivalue(struct, idx) do
    elem(struct.items, elem(struct.items, idx))
  end

  defp parse_args(struct, arg_count, op) do
    [100, 1000]
      |> Enum.take(arg_count)
      |> Enum.map(&(Integer.mod(Integer.floor_div(op, &1), 10)))
      |> Enum.with_index()
      |> Enum.map(fn
        {@immediate, offset} -> elem(struct.items, struct.idx + offset + 1)
        {@parameter, offset} -> ivalue(struct, struct.idx + offset + 1)
      end)
      |> Enum.to_list()
      |> List.to_tuple()
  end

  # TODO validate exit has 000 for its parse
  defp get_op(struct) when elem(struct.items, struct.idx) == @exit do
    [@exit, nil, nil]
  end

  defp get_op(struct) do
    idx = struct.idx
    full_op = elem(struct.items, idx)
    op = Integer.mod(full_op, 100)

    count = @arg_count[op]
    args = parse_args(struct, count, full_op)

    dest = case op do
      @add -> elem(struct.items, idx + 3)
      @mul -> elem(struct.items, idx + 3)
      @input -> elem(struct.items, idx + 1)
      @output -> elem(args, 0) # output is immediate vs parameter mode
      @jump_if_true -> elem(struct.items, idx + 2)
      @jump_if_false -> elem(struct.items, idx + 2)
      @equal -> elem(struct.items, idx + 3)
      @less_than -> elem(struct.items, idx + 3)
    end

    [op, args, dest]
  end

  def peek_next_instruction(struct) when elem(struct.items, struct.idx) == 99 do
    @exit
  end

  def peek_next_instruction(struct) do
    op = Integer.mod(elem(struct.items, struct.idx), 100)
    jmp = @prog_counter[op]
    elem(struct.items, struct.idx + jmp)
  end

  defp debug_op(struct, [op, args, dest]) do
    case op do
      @add -> IO.puts("#{struct.idx}: add(#{elem(args, 0)} + #{elem(args, 1)}) -> #{dest}")
      @mul -> IO.puts("#{struct.idx}: mul(#{elem(args, 0)} * #{elem(args, 1)}) -> #{dest}")
      @input -> IO.puts("#{struct.idx}: input(#{struct.input}) -> #{dest}")
      @output -> IO.puts("#{struct.idx}: output(#{dest})")

      @jump_if_true when elem(args, 0) != 0 ->
        IO.puts("#{struct.idx}: jump_if_true jumping to #{dest}")

      @jump_if_true when elem(args, 0) == 0 ->
        IO.puts("#{struct.idx}: jump_if_true not jumping")

      @jump_if_false when elem(args, 0) == 0 ->
        IO.puts("#{struct.idx}: jump_if_false jumping to #{dest}")

      @jump_if_false when elem(args, 0) != 0 ->
        IO.puts("#{struct.idx}: jump_if_false not jumping")

      @equal when elem(args, 0) == elem(args, 1) ->
        IO.puts("#{struct.idx}: equal: setting #{dest} to 1")

      @equal when elem(args, 0) != elem(args, 1) ->
        IO.puts("#{struct.idx}: equal: setting #{dest} to 0")

      @less_than when elem(args, 0) < elem(args, 1) ->
        IO.puts("#{struct.idx}: less_than: setting #{dest} to 1")

      @less_than when elem(args, 0) >= elem(args, 1) ->
        IO.puts("#{struct.idx}: less_than: setting #{dest} to 0")
    end
  end

  defp debug_state(struct) do
    IO.puts("IntComp(last_output = #{struct.last_output})")
  end

  def step(struct) when elem(struct.items, struct.idx) == 99 do
    {struct, {:finished}}
  end

  def step(struct) when struct.last_output != 0 and elem(struct.items, struct.idx) != 99 do
    {struct, {:error, "bad last_output"}}
  end

  def step(struct) do
    op = get_op(struct)

    if struct.debug do
      debug_state(struct)
      debug_op(struct, op)
    end

    struct = case op do
      [@add, {a, b}, dest] ->
        add = a + b
        update_value(struct, dest, add)

      [@mul, {a, b}, dest] ->
        mul = a * b
        update_value(struct, dest, mul)

      [@input, {}, dest] -> update_value(struct, dest, struct.input)
      [@output, {_}, out] -> update_last_output(struct, out)
      [@less_than, {a, b}, dest] when a >= b -> update_value(struct, dest, 0)
      [@less_than, {a, b}, dest] when a < b -> update_value(struct, dest, 1)
      [@equal, {a, b}, dest] when a == b -> update_value(struct, dest, 1)
      [@equal, {a, b}, dest] when a != b -> update_value(struct, dest, 0)

      # these instructions update the program counter
      # so they are excluded from the update program counter section
      [@jump_if_true, {a}, dest] when a != 0 -> update_program_counter_to(struct, dest)
      [@jump_if_true, {a}, _] when a == 0 -> update_program_counter(struct, 3)
      [@jump_if_false, {a}, dest] when a != 0 -> update_program_counter_to(struct, dest)
      [@jump_if_false, {a}, _] when a == 0 -> update_program_counter(struct, 3)
    end

    code = Enum.at(op, 0)
    struct = case code do
      @jump_if_true -> struct
      @jump_if_false -> struct
      _ -> update_program_counter(struct, @prog_counter[code])
    end

    {struct, {:ok}}
  end

  def run(struct) do
    case step(struct) do
      {s, {:ok}} -> run(s)
      {s, {:finished}} -> s
      {s, {:error, msg}} ->
        IO.puts("run errored: #{msg}")
        s
    end
  end

  defimpl String.Chars, for: IntComp do
    def to_string(%IntComp{idx: idx, items: items}) do
      op = elem(items, idx)
      items = for i <- idx..idx + 4, i < tuple_size(items), do: elem(items, i)
      str_items = Enum.join(items, ", ")
      "IntComp(idx = #{idx} op = #{op}) - items: #{str_items}"
    end
  end

end

