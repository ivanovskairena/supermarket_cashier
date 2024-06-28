defmodule SupermarketCashier.PricingRules.BuyOneGetOneFree do
  @behaviour SupermarketCashier.PricingRule

  @doc """
  Applies the buy-one-get-one-free rule to the given count of items.

  ## Examples

      iex> BuyOneGetOneFree.apply_rule(2, 3.11)
      3.11

      iex> BuyOneGetOneFree.apply_rule(3, 3.11)
      6.22
  """
  def apply_rule(count, price) do
    free_items = div(count, 2)
    total_price_items = count - free_items
    total_price_items * price
  end
end
