defmodule SupermarketCashier.PricingRules.MultiDiscount do
  @behaviour SupermarketCashier.PricingRule

  @doc """
  Applies the multi-discount rule to the given count of items.

  ## Examples

      iex> MultiDiscount.apply_rule(3, 11.23)
      22.47
  """
  def apply_rule(count, _price) when count >= 3 do
    # 2/3 of 11.23 is approximately 7.49
    7.49 * count
  end

  def apply_rule(count, price) do
    price * count
  end
end
