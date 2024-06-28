defmodule SupermarketCashier.OrderTest do
  use ExUnit.Case

  alias SupermarketCashier.Order

  test "creates a new order" do
    pricing_rules = [
      {SupermarketCashier.PricingRules.BuyOneGetOneFree, :apply},
      {SupermarketCashier.PricingRules.BulkDiscount, :apply},
      {SupermarketCashier.PricingRules.MultiDiscount, :apply}
    ]

    order = Order.new(pricing_rules)
    assert order.pricing_rules == pricing_rules
    assert order.items == []
  end
end
