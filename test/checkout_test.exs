defmodule SupermarketCashier.CheckoutTest do
  use ExUnit.Case
  alias SupermarketCashier.Checkout

  describe "add_product/2" do
    test "adds a product to the cart" do
      {:ok, pid} = Checkout.start_link()

      assert :ok =
               Checkout.add_product(pid, %Product{code: "GR1", name: "Green Tea", price: 3.11})

      assert Checkout.total(pid) == 3.11
    end
  end

  describe "total/1" do
    test "calculates the total price of the cart" do
      {:ok, pid} = Checkout.start_link()
      :ok = Checkout.add_product(pid, %Product{code: "GR1", name: "Green Tea", price: 3.11})
      :ok = Checkout.add_product(pid, %Product{code: "SR1", name: "Strawberries", price: 5.00})
      assert Checkout.total(pid) == 8.11
    end
  end
end
