defmodule SupermarketCashier.PricingRules.BulkDiscount do
  @behaviour SupermarketCashier.PricingRule

  @doc """
  Applies the bulk discount rule to the given count of items.

  ## Examples

      iex> BulkDiscount.apply_rule(3, 5.00)
      13.50
  """
  def apply_rule(count, _price) when count >= 3 do
    4.50 * count
  end

  def apply_rule(count, price) do
    price * count
  end
end
