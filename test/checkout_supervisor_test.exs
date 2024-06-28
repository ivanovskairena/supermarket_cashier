defmodule SupermarketCashier.CheckoutSupervisorTest do
  use ExUnit.Case
  alias SupermarketCashier.CheckoutSupervisor

  describe "checkout!/1" do
    test "starts a new checkout process with valid pricing rules" do
      {:ok, _pid} = CheckoutSupervisor.start_link(name: __MODULE__)
      pricing_rules = [{SupermarketCashier.PricingRules.BuyOneGetOneFree, :apply_rule}]
      assert {:ok, checkout_pid} = CheckoutSupervisor.checkout!(pricing_rules)
      assert Process.alive?(checkout_pid)
    end
  end
end
