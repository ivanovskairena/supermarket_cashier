defmodule SupermarketCashier.PricingRules.MultiDiscount do
  @behaviour SupermarketCashier.PricingRule

  @doc """
  Applies the multi-discount rule to the given count of items.

  ## Examples

      iex> MultiDiscount.apply_rule(3, 11.23)
      22.47
  """
  def apply_rule(_count, _price), do: 0.0
end
