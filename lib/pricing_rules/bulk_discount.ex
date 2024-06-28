efmodule SupermarketCashier.PricingRules.BulkDiscount do
  @behaviour SupermarketCashier.PricingRule

  @doc """
  Applies the bulk discount rule to the given count of items.

  ## Examples

      iex> BulkDiscount.apply_rule(3, 5.00)
      13.50
  """
  def apply_rule(_count, _price), do: 0.0
end
