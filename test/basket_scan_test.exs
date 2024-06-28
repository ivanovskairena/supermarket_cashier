defmodule SupermarketCashier.BasketScanTest do
  @moduledoc """
  Tests for the helper functions for scanning items from a whole basket and returning the formatted total price.
  """
  use ExUnit.Case

  alias SupermarketCashier.{BasketScan, PricingRules}

  setup do
    pricing_rules = [
      {PricingRules.BuyOneGetOneFree, :apply_rule},
      {PricingRules.BulkDiscount, :apply_rule},
      {PricingRules.MultiDiscount, :apply_rule}
    ]

    {:ok, pricing_rules: pricing_rules}
  end

  test "test basket with BasketScan", %{pricing_rules: pricing_rules} do
    total = BasketScan.test_basket(pricing_rules, ["GR1", "SR1", "GR1", "GR1", "CF1"])
    assert total == "£22.45"
  end
end
