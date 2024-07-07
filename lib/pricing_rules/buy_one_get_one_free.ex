defmodule SupermarketCashier.PricingRules.BuyOneGetOneFree do
  @moduledoc """
  PricingRule for applying the buy-one-get-one-free rule to the given count of items.
  If you buy one, you get one free offers of green tea.

  ## Examples

      iex> BuyOneGetOneFree.apply_rule(2, Decimal.new("3.11"))
      Decimal.new("3.11")

      iex> BuyOneGetOneFree.apply_rule(3, Decimal.new("3.11"))
      Decimal.new("6.22")
  """
  import Decimal, only: [new: 1, sub: 2, mult: 2]

  @behaviour SupermarketCashier.PricingRule

  @spec apply_rule(list(), Decimal.t()) :: Decimal.t()
  def apply_rule(items, total) do
    green_tea_items = Enum.filter(items, &(&1.code == "GR1"))

    discount =
      if length(green_tea_items) > 0 do
        free_items_count = Kernel.div(length(green_tea_items), 2)
        price_per_item = Enum.at(green_tea_items, 0).price
        mult(new(free_items_count), price_per_item)
      else
        new(0)
      end

    sub(total, discount)
  end
end
