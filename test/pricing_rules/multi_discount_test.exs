defmodule SupermarketCashier.PricingRules.MultiDiscountTest do
  use ExUnit.Case
  alias SupermarketCashier.PricingRules.MultiDiscount
  alias SupermarketCashier.Product
  import Decimal, only: [from_float: 1, compare: 2, round: 2]

  describe "apply_rule/2" do
    test "applies multi-discount correctly" do
      items = [
        %Product{code: "CF1", price: from_float(11.23)},
        %Product{code: "CF1", price: from_float(11.23)},
        %Product{code: "CF1", price: from_float(11.23)}
      ]

      result = MultiDiscount.apply_rule(items, from_float(33.69))
      expected_result = from_float(22.46)

      assert compare(round(result, 2), round(expected_result, 2)) == :eq

      items = [
        %Product{code: "CF1", price: from_float(11.23)},
        %Product{code: "CF1", price: from_float(11.23)}
      ]

      result = MultiDiscount.apply_rule(items, from_float(22.46))
      assert compare(round(result, 2), from_float(22.46)) == :eq
    end
  end
end
