defmodule SupermarketCashier.PricingRule do
  @moduledoc """
  Behavior definition for pricing rules.

  This module defines the behavior that all pricing rules must implement. It provides a default implementation for `apply_rule/2` and a no-op discount function.
  """

  @callback apply_rule(items :: list(), total :: float()) :: float()

  @doc """
  Default implementation for applying a pricing rule.

  This implementation does nothing and returns the total unchanged.

  ## Examples

      iex> SupermarketCashier.PricingRule.apply_rule([], 10.0)
      10.0
  """
  def apply_rule(_items, total) do
    total
  end

  @doc """
  No discount pricing rule.

  This function is a no-op and returns the total unchanged.

  ## Examples

      iex> SupermarketCashier.PricingRule.no_discount([], 10.0)
      10.0
  """
  def no_discount(_items, total), do: total
end
