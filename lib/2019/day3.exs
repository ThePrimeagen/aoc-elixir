defmodule Point do
  defstruct x: 0, y: 0

  def origin() do
    %Point{}
  end

  def parse(start, unparsed) do
    {dir, val} = String.split_at(unparsed, 1)
    val = String.to_integer(val)
    case {dir, val} do
      {"R", x} -> %Point{start | x: start.x + x}
      {"L", x} -> %Point{start | x: start.x - x}
      {"U", y} -> %Point{start | y: start.y - y}
      {"D", y} -> %Point{start | y: start.y + y}
    end
  end
end

defmodule Line do
  defstruct p1: %Point{x: 0, y: 0}, p2: %Point{x: 0, y: 0}

  def from(%Point{} = p1, %Point{} = p2) do
    %Line{p1: p1, p2: p2}
  end

  def len(%Line{p1: p1, p2: p2}) do
    abs(p2.x - p1.x) + abs(p2.y - p1.y)
  end

  def intersect(%Line{p1: %Point{x: x1, y: y1}, p2: %Point{x: x2, y: y2}},
                %Line{p1: %Point{x: x3, y: y3}, p2: %Point{x: x4, y: y4}}) do

    # Calculate the denominators for t and u
    denominator = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)

    # If denominator is zero, the lines are parallel or collinear
    if denominator == 0 do
      {:error, :parallel_or_collinear}
    else
      # Calculate t and u using the intersection formulas
      t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denominator
      u = ((x1 - x3) * (y1 - y2) - (y1 - y3) * (x1 - x2)) / denominator

      # Check if t and u are between 0 and 1 (inclusive)
      if t >= 0 and t <= 1 and u >= 0 and u <= 1 do
        # Calculate the intersection point
        intersection_x = x1 + t * (x2 - x1)
        intersection_y = y1 + t * (y2 - y1)
        {:ok, %Point{x: intersection_x, y: intersection_y}}
      else
        {:error, :no_intersection}
      end
    end
  end
end

[a, b] =
  File.stream!("./2019/day3.test", :line)
  |> Stream.map(&(String.trim(&1)))
  |> Stream.map(&([:start | String.split(&1, ",")]))
  |> Stream.map(&(
      Enum.scan(&1, nil, fn
        :start, _ -> Point.origin()
        x, prev -> Point.parse(prev, x)
      end))
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn x -> Line.from(Enum.at(x, 0), Enum.at(x, 1)) end))
  |> Enum.to_list()

closest = for line_a <- a,
    line_b <- b,
    reduce: 3000 do
  acc ->
      IO.puts(acc)
     case {line_a, line_b, acc, Line.intersect(line_a, line_b)} do
      {l1, l2, acc, _} when l1.p1.x == 0 and l1.p1.y == 0 and l2.p1.x == 0 and l2.p1.y == 0 -> acc
      {_, _, acc, {:error, _}} -> acc
      {_, _, prev, {:ok, p}} when prev < abs(p.x) + abs(p.y) -> prev
      {_, _, _, {:ok, p}} -> abs(p.x) + abs(p.y)
    end
end

IO.inspect(closest)
IO.puts("part 2")

defmodule DistanceCalc do
  defstruct best: 10_000_000, curr: 0

  def new() do
    %DistanceCalc{}
  end

  def push_best(dist, best) when best >= dist.best do
    dist
  end

  def push_best(dist, best) do
    %DistanceCalc{dist | best: best}
  end

  def add(dist, curr) do
    %DistanceCalc{dist | curr: dist.curr + curr}
  end

end

defimpl String.Chars, for: DistanceCalc do
  def to_string(%DistanceCalc{best: best, curr: curr}) do
    "DistanceCalc(best = #{best} curr = #{curr})"
  end
end

defimpl String.Chars, for: Point do
  def to_string(%Point{x: x, y: y}) do
    "Point(x = #{x} y = #{y})"
  end
end

defimpl String.Chars, for: Line do
  def to_string(%Line{p1: p1, p2: p2}) do
    "Line(p1 = #{p1} p2 = #{p2})"
  end
end

## I am on Day 3 part 2 2019
## i just realized that while reading it you just need to test line_a
## against set B until it finds the first intersection and that
## is in fact the score!  its that easy!
## i just put a really large number
## DANGIT ITS NOT REDUCE_WHILE
## F
## i am dumb
answer = Enum.reduce(a, DistanceCalc.new(), fn line_a, dist ->
  IO.puts("outer reduce #{dist} -- #{line_a}")

  ## Ok lets start from the beginning, lets print out the line + the current
  #distance and figure shit out

  ## yayayay???

  res = Enum.with_index(b) |> Enum.reduce_while({:error, 0},

    fn {line_b, idx}, _ when
      line_b.p1.x == 0 and line_b.p1.y == 0 and
      line_a.p1.x == 0 and line_a.p1.y == 0 ->
        {:cont, {:error, Line.len(line_b)}}

    {line_b, idx}, {_, b_dist} ->
    IO.puts("    #{idx} inner reduce -- #{line_b} current dist: #{b_dist}")

    ## slowly count the distance
    ## can you do block statements in case??
    case Line.intersect(line_a, line_b) do
      {:ok, p} ->
        # do i need to get the steps to the intersection?
        # my guess is yes
        # i'll deal with that later
        # i need to deal with point to point distance now
        line_a_dist = Line.len(Line.from(p, line_a.p1))
        line_b_dist = Line.len(Line.from(p, line_b.p1))
        p_dist = line_a_dist + line_b_dist
          # ok i am missing something here
        IO.puts("    #{idx} found intersection between #{line_a} and #{line_b} with point #{p}")
        IO.puts("    #{idx} found intersection with p dist #{p_dist}(#{line_a_dist}, #{line_b_dist})")

        {:halt, {:ok, b_dist + p_dist}}
      {:error, _} -> {:cont, {:error, b_dist + Line.len(line_b)}}
    end
  end)

  # GOT EM
  case res do
    {:error, _} -> DistanceCalc.add(dist, Line.len(line_a))
    {_, found_distance} ->
      ## THAT IS SO GOOD
      ## ok lets think on this...
      ## i need to know thet distances i am working with
      IO.puts("Dist: #{dist} -- found #{found_distance}")
      DistanceCalc.push_best(dist, found_distance + dist.curr)
  end
end)

IO.inspect(answer)
