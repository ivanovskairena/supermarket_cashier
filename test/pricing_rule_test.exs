defmodule SupermarketCashier.PricingRuleTest do
  use ExUnit.Case

  describe "apply_rule/2" do
    test "is a behavior" do
      assert Code.ensure_loaded?(SupermarketCashier.PricingRule)
    end
  end
end
