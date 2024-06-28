defmodule SupermarketCashier.Order do
  @moduledoc """
  Defines an order with items and pricing rules.
  """
  alias SupermarketCashier.Product

  defstruct items: [], pricing_rules: [], total: 0.0

  @type t() :: %__MODULE__{
          items: [Product.t()],
          pricing_rules: [{module(), atom()}],
          total: float()
        }

  def new(pricing_rules) do
    %__MODULE__{pricing_rules: pricing_rules}
  end
end
