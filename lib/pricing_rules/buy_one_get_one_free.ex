defmodule SupermarketCashier.PricingRules.BuyOneGetOneFree do
  @behaviour SupermarketCashier.PricingRule

  @doc """
  Applies the buy-one-get-one-free rule to the given count of items.

  ## Examples

      iex> BuyOneGetOneFree.apply_rule(2, 3.11)
      3.11
  """
  def apply_rule(_count, _price), do: 0.0
end
