defmodule SupermarketCashier.CustomScan do
  @moduledoc """
  Custom scan macros for handling orders.

  This module provides macros to scan products into a basket and to calculate
  the total price of the basket. It uses custom operators for a more expressive
  syntax when scanning products and getting the total.
  """

  alias SupermarketCashier.{CustomScan, Product, Order}
  import Decimal, only: [new: 1, add: 2, round: 3, to_string: 2]

  @doc """
  Macro for scanning a product into the basket.

  ## Examples

      iex> basket = %SupermarketCashier.Order{}
      iex> basket <~ "GR1"
      %SupermarketCashier.Order{items: [%SupermarketCashier.Product{code: "GR1", name: "Green Tea", price: Decimal.new("3.11")}]}

      iex> basket <~ "INVALID"
      %SupermarketCashier.Order{}
  """
  defmacro basket <~ product_code do
    quote bind_quoted: [basket: basket, product_code: product_code] do
      case Product.get_product(product_code) do
        nil ->
          basket

        product ->
          updated_items = [product | basket.items]

          new_total =
            CustomScan.calculate_total(updated_items, basket.pricing_rules)

          %Order{basket | items: updated_items, total: new_total}
      end
    end
  end

  @doc """
  Macro for getting the total price of the basket.

  ## Examples

      iex> basket = %SupermarketCashier.Order{total: Decimal.new("3.11")}
      iex> basket ~> :total
      "£3.11"
  """
  defmacro basket ~> :total do
    quote bind_quoted: [basket: basket] do
      CustomScan.format_price(basket.total)
    end
  end

  @doc """
  Calculates the total price of the items with applied pricing rules.

  ## Examples

      iex> items = [%SupermarketCashier.Product{price: Decimal.new("3.11")}, %SupermarketCashier.Product{price: Decimal.new("5.00")}]
      iex> pricing_rules = []
      iex> SupermarketCashier.CustomScan.calculate_total(items, pricing_rules)
      #Decimal<8.11>
  """
  def calculate_total(items, pricing_rules) do
    base_total = Enum.reduce(items, new("0.00"), fn item, acc -> add(acc, item.price) end)

    Enum.reduce(pricing_rules, base_total, fn {module, function}, acc ->
      apply(module, function, [items, acc])
    end)
  end

  @doc """
  Formats the total price with the currency symbol.

  ## Examples

      iex> SupermarketCashier.Utils.format_price(Decimal.from_float(3.115))
      "£3.12"

      iex> SupermarketCashier.Utils.format_price(Decimal.from_float(3.114))
      "£3.11"
  """
  def format_price(total) do
    # Rounded following the IEEE 754 standard
    # I use the :half_even rounding mode, also known as "bankers' rounding."
    # This mode rounds to the nearest even number when the number is exactly halfway between two possible rounded values.
    # This method helps to reduce rounding bias in financial calculations.
    rounded_total = round(total, 2, :half_even)
    "£" <> to_string(rounded_total, :normal)
  end
end
