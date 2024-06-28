defmodule SupermarketCashier.OrderTest do
  use ExUnit.Case
  alias SupermarketCashier.{Order, Product}

  describe "add_product/2" do
    test "adds a product to the order" do
      order = %Order{}
      product = %Product{code: "GR1", name: "Green tea", price: 3.11}

      assert order = Order.add_product(order, product)
      assert length(order.items) == 1
      assert Enum.at(order.items, 0) == product
    end
  end

  describe "total_price/1" do
    test "calculates the total price of the order" do
      order = %Order{}
      product1 = %Product{code: "GR1", name: "Green tea", price: 3.11}
      product2 = %Product{code: "SR1", name: "Strawberries", price: 5.00}

      order = Order.add_product(order, product1)
      order = Order.add_product(order, product2)

      assert Order.total_price(order) == 8.11
    end
  end
end
