defmodule SupermarketCashier.CustomScanTest do
  use ExUnit.Case

  alias SupermarketCashier.{Order, Product, PricingRules}
  import SupermarketCashier.CustomScan

  test "custom scan functionality" do
    basket = %SupermarketCashier.Order{items: [], pricing_rules: []}
    basket = basket <~ "GR1"
    basket = basket <~ "SR1"
    basket = basket <~ "GR1"
    basket = basket <~ "CF1"

    total = basket ~> :total
    assert total == "£22.45"
  end

  test "custom scan with invalid product" do
    basket = %Order{items: [], pricing_rules: []}
    basket = basket <~ "INVALID"

    total = basket ~> :total
    assert total == "£0.00"
  end

  test "custom scan with different basket" do
    basket = %Order{items: [], pricing_rules: []}
    basket = basket <~ "CF1"
    basket = basket <~ "GR1"
    basket = basket <~ "SR1"
    total = basket ~> :total
    assert total == "£19.34"
  end

  test "calculate total with pricing rules" do
    items = [
      %Product{code: "GR1", name: "Green tea", price: 3.11},
      %Product{code: "SR1", name: "Strawberries", price: 5.00},
      %Product{code: "CF1", name: "Coffee", price: 11.23}
    ]

    pricing_rules = [
      {PricingRules.BuyOneGetOneFree, :apply_rule},
      {PricingRules.BulkDiscount, :apply_rule},
      {PricingRules.MultiDiscount, :apply_rule}
    ]

    total = calculate_total(items, pricing_rules)
    assert total == 19.34
  end

  test "format price correctly" do
    total = 19.345
    formatted_price = format_price(total)
    assert formatted_price == "£19.34"
  end
end
