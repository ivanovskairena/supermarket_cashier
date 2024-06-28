defmodule SupermarketCashier.PricingRule do
  @callback apply_rule(count :: integer, price :: float) :: float
end
