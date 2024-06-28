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

  @spec apply_rule(list(), float()) :: float()
  def apply_rule(items, total) do
    green_tea_items = Enum.filter(items, &(&1.code == "GR1"))

    discount =
      if length(green_tea_items) > 0,
        do: div(length(green_tea_items), 2) * Enum.at(green_tea_items, 0).price,
        else: 0

    Float.round(total - discount, 2)
  end
end
