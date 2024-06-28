defmodule SupermarketCashier.CustomScan do
  @moduledoc """
  Custom scan macros for handling orders.
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

  defmacro basket ~> :total do
    quote bind_quoted: [basket: basket] do
      SupermarketCashier.CustomScan.format_price(basket.total)
    end
  end

  def calculate_total(items, pricing_rules) do
    base_total = Enum.reduce(items, 0.0, fn item, acc -> acc + item.price end)

    Enum.reduce(pricing_rules, base_total, fn {module, function}, acc ->
      apply(module, function, [items, acc])
    end)
  end

  def format_price(total) do
    rounded_total = Float.round(total, 2)

    :io_lib.format("£~.2f", [rounded_total])
    |> IO.iodata_to_binary()
  end
end
