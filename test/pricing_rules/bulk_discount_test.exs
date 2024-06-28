defmodule SupermarketCashier.PricingRules.BulkDiscountTest do
  use ExUnit.Case
  alias SupermarketCashier.PricingRules.BulkDiscount
  alias SupermarketCashier.Product

  describe "apply_rule/2" do
    test "applies bulk discount correctly" do
      items = [
        %Product{code: "SR1", price: 5.00},
        %Product{code: "SR1", price: 5.00},
        %Product{code: "SR1", price: 5.00}
      ]

      assert BulkDiscount.apply_rule(items, 15.00) == 13.50

      items = [%Product{code: "SR1", price: 5.00}, %Product{code: "SR1", price: 5.00}]
      assert BulkDiscount.apply_rule(items, 10.00) == 10.00
    end
  end
end
