defmodule AocElixirTest do
  use ExUnit.Case
  doctest AocElixir

  test "greets the world" do
    assert AocElixir.hello() == :world
  end
end
