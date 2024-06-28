defmodule SupermarketCashier.PricingRules.MultiDiscountTest do
  use ExUnit.Case
  alias SupermarketCashier.PricingRules.MultiDiscount

  describe "apply_rule/2" do
    test "applies multi-discount correctly" do
      assert MultiDiscount.apply_rule(3, 11.23) == 22.47
      assert MultiDiscount.apply_rule(2, 11.23) == 22.46
    end
  end
end
