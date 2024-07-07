defmodule SupermarketCashier.PricingRules.BulkDiscount do
  @moduledoc """
  Pricing for applying the bulk discount rule to the given count of items.
  If you buy 3 or more strawberries, the price should drop to £4.50 per strawberry.

  ## Examples

      iex> BulkDiscount.apply_rule(3, Decimal.new("5.00"))
      Decimal.new("13.50")
  """
  import Decimal, only: [new: 1, sub: 2, mult: 2]

  @behaviour SupermarketCashier.PricingRule

  @spec apply_rule(list(), Decimal.t()) :: Decimal.t()
  def apply_rule(items, total) do
    strawberry_items = Enum.filter(items, &(&1.code == "SR1"))

    if length(strawberry_items) >= 3 do
      original_price = Enum.at(strawberry_items, 0).price
      discount_price = new("4.50")
      discount_per_item = sub(original_price, discount_price)
      discount = mult(discount_per_item, new(length(strawberry_items)))
      sub(total, discount)
    else
      total
    end
  end
end
