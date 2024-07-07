defmodule SupermarketCashier.CustomScanTest do
  use ExUnit.Case

  alias SupermarketCashier.{Order, Product, PricingRules}
  import SupermarketCashier.CustomScan
  import Decimal, only: [from_float: 1]

  test "custom scan functionality" do
    basket = %Order{items: [], pricing_rules: [], total: from_float(0.0)}
    basket = basket <~ "GR1"
    basket = basket <~ "SR1"
    basket = basket <~ "GR1"
    basket = basket <~ "CF1"

    total = basket ~> :total
    assert total == "£22.45"
  end

  test "custom scan with invalid product" do
    basket = %Order{items: [], pricing_rules: [], total: from_float(0.0)}
    basket = basket <~ "INVALID"

    total = basket ~> :total
    assert total == "£0.00"
  end

  test "custom scan with different basket" do
    basket = %Order{items: [], pricing_rules: [], total: from_float(0.0)}
    basket = basket <~ "CF1"
    basket = basket <~ "GR1"
    basket = basket <~ "SR1"
    total = basket ~> :total
    assert total == "£19.34"
  end

  test "calculate total with pricing rules" do
    items = [
      %Product{code: "GR1", name: "Green tea", price: from_float(3.11)},
      %Product{code: "SR1", name: "Strawberries", price: from_float(5.00)},
      %Product{code: "CF1", name: "Coffee", price: from_float(11.23)}
    ]

    pricing_rules = [
      {PricingRules.BuyOneGetOneFree, :apply_rule},
      {PricingRules.BulkDiscount, :apply_rule},
      {PricingRules.MultiDiscount, :apply_rule}
    ]

    total = calculate_total(items, pricing_rules)
    assert total == from_float(19.34)
  end

  # Rounded following the IEEE 754 standard
  # I use the :half_even rounding mode, also known as "bankers' rounding."
  # This mode rounds to the nearest even number when the number is exactly halfway between two possible rounded values.
  # This method helps to reduce rounding bias in financial calculations.
  test "format price correctly" do
    total = from_float(19.345)
    formatted_price = format_price(total)
    assert formatted_price == "£19.34"
  end
end
