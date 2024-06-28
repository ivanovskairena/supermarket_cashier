defmodule SupermarketCashier.PricingRules.MultiDiscount do
  @moduledoc """
  PricingRule for applying the multi-discount rule to the given count of items.
  If you buy 3 or more coffees, the price of all coffees should drop to two thirds of the original price.

  ## Examples

      iex> MultiDiscount.apply_rule(3, 11.23)
      22.47
  """
  @behaviour SupermarketCashier.PricingRule

  @spec apply_rule(list(), float()) :: float()
  def apply_rule(items, total) do
    multiple_items = Enum.filter(items, &(&1.code == "CF1"))

    if length(multiple_items) >= 3 do
      total_discount = Enum.count(multiple_items) * (Enum.at(multiple_items, 0).price / 3)
      Float.round(total - total_discount, 2)
    else
      Float.round(total, 2)
    end
  end
end
