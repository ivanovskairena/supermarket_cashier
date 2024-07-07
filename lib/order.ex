defmodule SupermarketCashier.Order do
  @moduledoc """
  Defines an order with items and pricing rules.

  This struct holds the items in the order, the pricing rules to be applied, and the total price.
  """

  alias SupermarketCashier.Product
  import Decimal, only: [new: 1]

  defstruct items: [], pricing_rules: [], total: new(0)

  @type t() :: %__MODULE__{
          items: [Product.t()],
          pricing_rules: [{module(), atom()}],
          total: Decimal.t()
        }

  @doc """
  Creates a new order with the given pricing rules.

  ## Examples

      iex> SupermarketCashier.Order.new([{SupermarketCashier.PricingRules.BuyOneGetOneFree, :apply_rule}])
      %SupermarketCashier.Order{pricing_rules: [{SupermarketCashier.PricingRules.BuyOneGetOneFree, :apply_rule}], items: [], total: Decimal.new(0)}
  """
  def new(pricing_rules) do
    %__MODULE__{pricing_rules: pricing_rules, total: Decimal.new(0)}
  end
end
