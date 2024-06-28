defmodule SupermarketCashier.BasketScan do
  @moduledoc """
  Helper functions for scanning items from a whole basket and returning the formatted total price.
  """

  alias SupermarketCashier.Checkout

  @doc """
  Tests the basket by scanning items and returning the formatted total price.

  ## Examples

      iex> pricing_rules = [
      ...>   {SupermarketCashier.PricingRules.BuyOneGetOneFree, :apply_rule},
      ...>   {SupermarketCashier.PricingRules.BulkDiscount, :apply_rule},
      ...>   {SupermarketCashier.PricingRules.MultiDiscount, :apply_rule}
      ...> ]
      iex> items = ["GR1", "SR1", "GR1", "GR1", "CF1"]
      iex> SupermarketCashier.BasketScan.test_basket(pricing_rules, items)
      "£22.45"
  """
  def test_basket(pricing_rules, items) do
    {:ok, pid} = Checkout.new(pricing_rules)
    Enum.each(items, fn item -> Checkout.scan(pid, item) end)
    Checkout.total(pid)
  end
end
