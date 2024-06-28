defmodule SupermarketCashier.PricingRules.MultiDiscountTest do
  use ExUnit.Case
  alias SupermarketCashier.PricingRules.MultiDiscount
  alias SupermarketCashier.Product

  describe "apply_rule/2" do
    test "applies multi-discount correctly" do
      items = [
        %Product{code: "CF1", price: 11.23},
        %Product{code: "CF1", price: 11.23},
        %Product{code: "CF1", price: 11.23}
      ]

      assert MultiDiscount.apply_rule(items, 33.69) == 22.46

      items = [%Product{code: "CF1", price: 11.23}, %Product{code: "CF1", price: 11.23}]
      assert MultiDiscount.apply_rule(items, 22.46) == 22.46
    end
  end
end
