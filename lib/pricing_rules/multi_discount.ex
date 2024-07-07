defmodule SupermarketCashier.PricingRules.MultiDiscount do
  @moduledoc """
  PricingRule for applying the multi-discount rule to the given count of items.
  If you buy 3 or more coffees, the price of all coffees should drop to two thirds of the original price.

  ## Examples

      iex> MultiDiscount.apply_rule(3, 11.23)
      22.47
  """
  import Decimal, only: [new: 1, mult: 2, sub: 2]

  @behaviour SupermarketCashier.PricingRule

  @spec apply_rule(list(), Decimal.t()) :: Decimal.t()
  def apply_rule(items, total) do
    coffee_items = Enum.filter(items, &(&1.code == "CF1"))

    if length(coffee_items) >= 3 do
      original_price = Enum.at(coffee_items, 0).price
      discount_per_item = Decimal.div(original_price, new(3))
      total_discount = mult(discount_per_item, new(length(coffee_items)))
      sub(total, total_discount)
    else
      total
    end
  end
end
