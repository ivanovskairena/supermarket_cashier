defmodule SupermarketCashierTest do
  use ExUnit.Case
  doctest SupermarketCashier

  test "greets the world" do
    assert SupermarketCashier.hello() == :world
  end
end
