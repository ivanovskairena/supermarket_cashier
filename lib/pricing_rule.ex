defmodule SupermarketCashier.PricingRule do
  @moduledoc """
  Behavior definition for pricing rules.
  """
  @callback apply_rule(items :: list(), total :: float()) :: float()

  def apply_rule(_items, total) do
    total
  end

  def no_discount(_items, total), do: total
end
