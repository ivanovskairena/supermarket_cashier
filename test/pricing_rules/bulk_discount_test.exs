defmodule SupermarketCashier.PricingRules.BulkDiscountTest do
  use ExUnit.Case
  alias SupermarketCashier.PricingRules.BulkDiscount

  describe "apply_rule/2" do
    test "applies bulk discount correctly" do
      assert BulkDiscount.apply_rule(3, 5.00) == 13.50
      assert BulkDiscount.apply_rule(2, 5.00) == 10.00
    end
  end
end
