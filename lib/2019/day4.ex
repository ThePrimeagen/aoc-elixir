defmodule IntCompRunner do
  @ac 1
  @thermal 5

  def run(contents, input) do
    items = String.split(contents, ",")
      |> Enum.map(&(String.to_integer(String.trim(&1))))

    comp = IntComp.debug_computer(items, input)
    comp = IntComp.run(comp)

    {IntComp.prog_value(comp), comp.last_output}
  end

  def run_all() do

    # day 4.1
    {:ok, contents} = File.read("./lib/2019/day4.input")
    {_, output} = run(contents, @ac)

    if output != 5182797 do
      IO.puts("expected output to equal 5182797 but got #{output}")
    else
      IO.puts("day4.1 ran successfully")
    end

    {_, _} = run(contents, @thermal)
  end
end

IntCompRunner.run_all()
