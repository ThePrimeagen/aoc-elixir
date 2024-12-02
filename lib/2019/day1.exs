defmodule AOC do
  def calculate_mass(x) when x > 8 do
    fuel = Integer.floor_div(x, 3) - 2
    fuel + calculate_mass(fuel)
  end

  def calculate_mass(x) when x <= 8 do
    0
  end
end

File.stream!("./day1.input", :line)
|> Stream.map(&String.trim/1)
|> Stream.filter(&(byte_size(&1) > 0))
|> Stream.map(&String.to_integer/1)
|> Stream.map(&AOC.calculate_mass/1)
|> Enum.sum()
|> IO.inspect()
