defmodule SupermarketCashier.PricingRules.BuyOneGetOneFreeTest do
  use ExUnit.Case
  alias SupermarketCashier.PricingRules.BuyOneGetOneFree
  alias SupermarketCashier.Product
  import Decimal, only: [from_float: 1, compare: 2, round: 2]

  describe "apply_rule/2" do
    test "applies buy-one-get-one-free discount correctly" do
      items = [
        %Product{code: "GR1", price: from_float(3.11)},
        %Product{code: "GR1", price: from_float(3.11)}
      ]

      result = BuyOneGetOneFree.apply_rule(items, from_float(6.22))
      assert compare(round(result, 2), from_float(3.11)) == :eq

      items = [
        %Product{code: "GR1", price: from_float(3.11)},
        %Product{code: "GR1", price: from_float(3.11)},
        %Product{code: "GR1", price: from_float(3.11)}
      ]

      result = BuyOneGetOneFree.apply_rule(items, from_float(9.33))
      assert compare(round(result, 2), from_float(6.22)) == :eq
    end
  end
end
