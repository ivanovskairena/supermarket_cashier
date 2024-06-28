defmodule SupermarketCashier.PricingRules.BulkDiscount do
  @moduledoc """
  Pricing for applying the bulk discount rule to the given count of items.
  If you buy 3 or more strawberries, the price should drop to £4.50 per strawberry.

  ## Examples

      iex> BulkDiscount.apply_rule(3, 5.00)
      13.50
  """
  @behaviour SupermarketCashier.PricingRule

  @spec apply_rule(list(), float()) :: float()
  def apply_rule(items, total) do
    strawberry_items = Enum.filter(items, &(&1.code == "SR1"))

    if length(strawberry_items) >= 3 do
      discount = length(strawberry_items) * (Enum.at(strawberry_items, 0).price - 4.50)
      Float.round(total - discount, 2)
    else
      Float.round(total, 2)
    end
  end
end
