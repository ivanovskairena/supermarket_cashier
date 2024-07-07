defmodule SupermarketCashier.PricingRules.BulkDiscountTest do
  use ExUnit.Case
  alias SupermarketCashier.PricingRules.BulkDiscount
  alias SupermarketCashier.Product
  import Decimal, only: [from_float: 1, compare: 2, round: 2]

  describe "apply_rule/2" do
    test "applies bulk discount correctly" do
      items = [
        %Product{code: "SR1", price: from_float(5.00)},
        %Product{code: "SR1", price: from_float(5.00)},
        %Product{code: "SR1", price: from_float(5.00)}
      ]

      result = BulkDiscount.apply_rule(items, from_float(15.00))
      assert compare(round(result, 2), from_float(13.50)) == :eq

      items = [
        %Product{code: "SR1", price: from_float(5.00)},
        %Product{code: "SR1", price: from_float(5.00)}
      ]

      result = BulkDiscount.apply_rule(items, from_float(10.00))
      assert compare(round(result, 2), from_float(10.00)) == :eq
    end
  end
end
