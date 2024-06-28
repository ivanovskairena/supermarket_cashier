defmodule SupermarketCashier.PricingRules.BuyOneGetOneFreeTest do
  use ExUnit.Case
  alias SupermarketCashier.PricingRules.BuyOneGetOneFree

  describe "apply_rule/2" do
    test "applies buy-one-get-one-free discount correctly" do
      assert BuyOneGetOneFree.apply_rule(2, 3.11) == 3.11
      assert BuyOneGetOneFree.apply_rule(3, 3.11) == 6.22
    end
  end
end
