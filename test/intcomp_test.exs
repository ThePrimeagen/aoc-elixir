defmodule IntCompTest do
  use ExUnit.Case

  test "add" do
    comp = IntComp.computer([1,4,3,0,99], 0)
    comp = IntComp.run(comp)
    assert IntComp.prog_value(comp) == 99 + 0

    comp = IntComp.computer([101,4,3,0,99], 0)
    comp = IntComp.run(comp)
    assert IntComp.prog_value(comp) == 4 + 0

    comp = IntComp.computer([1101,4,3,0,99], 0)
    comp = IntComp.run(comp)
    assert IntComp.prog_value(comp) == 4 + 3

    comp = IntComp.computer([1001,4,3,0,99], 0)
    comp = IntComp.run(comp)
    assert IntComp.prog_value(comp) == 99 + 3
  end

  test "multiple" do
    comp = IntComp.computer([2,4,3,0,99], 0)
    comp = IntComp.run(comp)
    assert IntComp.prog_value(comp) == 99 * 0

    comp = IntComp.computer([102,4,3,0,99], 0)
    comp = IntComp.run(comp)
    assert IntComp.prog_value(comp) == 4 * 0

    comp = IntComp.computer([1102,4,3,0,99], 0)
    comp = IntComp.run(comp)
    assert IntComp.prog_value(comp) == 4 * 3

    comp = IntComp.computer([1002,4,3,0,99], 0)
    comp = IntComp.run(comp)
    assert IntComp.prog_value(comp) == 99 * 3
  end

  test "complex" do
    comp = IntComp.computer([
      1,9,10,9,    # 1    + 1
      102,9,3,10,  # 9    * 9
      1102,1,1,0,  # 2   * 81
      99
    ], 0)

    # out should be 12 in pos 1
    comp = IntComp.run(comp)
    assert IntComp.prog_value(comp) == 2 * 81
  end

  test "input" do
    comp = IntComp.computer([
      3,5,99,9,4,3
    ], 69)

    # out should be 12 in pos 1
    comp = IntComp.run(comp)
    assert elem(comp.items, 5) == 69
  end

  test "output" do
    comp = IntComp.computer([
      104,0,99,9,4,3
    ], 69)

    # out should be 12 in pos 1
    comp = IntComp.run(comp)
    assert comp.last_output == 0

    comp = IntComp.computer([
      4,4,99,9,4,3
    ], 69)

    # out should be 12 in pos 1
    comp = IntComp.run(comp)
    assert comp.last_output == 4
  end

end

