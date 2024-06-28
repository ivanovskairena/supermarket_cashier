defmodule SupermarketCashier.PricingRules.BuyOneGetOneFreeTest do
  use ExUnit.Case
  alias SupermarketCashier.PricingRules.BuyOneGetOneFree
  alias SupermarketCashier.Product

  describe "apply_rule/2" do
    test "applies buy-one-get-one-free discount correctly" do
      items = [%Product{code: "GR1", price: 3.11}, %Product{code: "GR1", price: 3.11}]
      assert BuyOneGetOneFree.apply_rule(items, 6.22) == 3.11

      items = [
        %Product{code: "GR1", price: 3.11},
        %Product{code: "GR1", price: 3.11},
        %Product{code: "GR1", price: 3.11}
      ]

      assert BuyOneGetOneFree.apply_rule(items, 9.33) == 6.22
    end
  end
end
