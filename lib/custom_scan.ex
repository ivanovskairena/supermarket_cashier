defmodule SupermarketCashier.CustomScan do
  @moduledoc """
  Custom scan macros for handling orders.

  This module provides macros to scan products into a basket and to calculate
  the total price of the basket. It uses custom operators for a more expressive
  syntax when scanning products and getting the total.
  """

  @doc """
  Macro for scanning a product into the basket.

  ## Examples

      iex> basket = %SupermarketCashier.Order{}
      iex> basket <~ "GR1"
      %SupermarketCashier.Order{items: [%SupermarketCashier.Product{code: "GR1", name: "Green Tea", price: 3.11}], total: 3.11}

      iex> basket <~ "INVALID"
      %SupermarketCashier.Order{}
  """
  defmacro basket <~ product_code do
    quote bind_quoted: [basket: basket, product_code: product_code] do
      case SupermarketCashier.Product.get_product(product_code) do
        nil ->
          basket

        product ->
          updated_items = [product | basket.items]

          new_total =
            SupermarketCashier.CustomScan.calculate_total(updated_items, basket.pricing_rules)

          %SupermarketCashier.Order{
            basket
            | items: updated_items,
              total: new_total
          }
      end
    end
  end

  @doc """
  Macro for getting the total price of the basket.

  ## Examples

      iex> basket = %SupermarketCashier.Order{total: 3.11}
      iex> basket ~> :total
      "£3.11"
  """
  defmacro basket ~> :total do
    quote bind_quoted: [basket: basket] do
      SupermarketCashier.CustomScan.format_price(basket.total)
    end
  end

  @doc """
  Calculates the total price of the items with applied pricing rules.

  ## Examples

      iex> items = [%SupermarketCashier.Product{price: 3.11}, %SupermarketCashier.Product{price: 5.00}]
      iex> pricing_rules = []
      iex> SupermarketCashier.CustomScan.calculate_total(items, pricing_rules)
      8.11
  """
  def calculate_total(items, pricing_rules) do
    base_total = Enum.reduce(items, 0.0, fn item, acc -> acc + item.price end)

    Enum.reduce(pricing_rules, base_total, fn {module, function}, acc ->
      apply(module, function, [items, acc])
    end)
  end

  @doc """
  Formats the total price with the currency symbol.

  ## Examples

      iex> SupermarketCashier.CustomScan.format_price(3.11)
      "£3.11"
  """
  def format_price(total) do
    rounded_total = Float.round(total, 2)

    :io_lib.format("£~.2f", [rounded_total])
    |> IO.iodata_to_binary()
  end
end
