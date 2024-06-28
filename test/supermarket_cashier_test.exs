defmodule SupermarketCashierTest do
  use ExUnit.Case

  describe "SupermarketCashier.add_product/2" do
    test "adds a product to the cart" do
      cart = []
      product = %Product{code: "GR1", name: "Green Tea", price: 3.11}

      assert SupermarketCashier.add_product(cart, product) == [
               %Product{code: "GR1", name: "Green Tea", price: 3.11}
             ]
    end
  end

  describe "SupermarketCashier.total_price/1" do
    test "calculates the total price of the cart" do
      cart = [
        %Product{code: "GR1", name: "Green Tea", price: 3.11},
        %Product{code: "SR1", name: "Strawberries", price: 5.00}
      ]

      assert SupermarketCashier.total_price(cart) == 8.11
    end
  end
end
