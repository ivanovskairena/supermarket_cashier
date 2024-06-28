defmodule SupermarketCashier.PricingRuleTest do
  use ExUnit.Case
  alias SupermarketCashier.PricingRule

  describe "apply_rule/2" do
    test "is a behavior" do
      assert Code.ensure_loaded?(SupermarketCashier.PricingRule)
      assert :apply_rule in Keyword.keys(SupermarketCashier.PricingRule.__info__(:functions))
    end

    test "default implementation returns the total unchanged" do
      items = []
      total = 10.0
      assert PricingRule.apply_rule(items, total) == total
    end

    test "no_discount function returns the total unchanged" do
      items = [%{code: "GR1", name: "Green Tea", price: 3.11}]
      total = 3.11
      assert PricingRule.no_discount(items, total) == total
    end

    test "custom pricing rule module implements apply_rule/2" do
      defmodule CustomRule do
        @behaviour SupermarketCashier.PricingRule

        @impl true
        def apply_rule(_items, total), do: total - 1.0
      end

      items = [%{code: "GR1", name: "Green Tea", price: 3.11}]
      total = 3.11
      assert CustomRule.apply_rule(items, total) == 2.11
    end
  end
end
