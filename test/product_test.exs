defmodule SupermarketCashier.ProductTest do
  use ExUnit.Case
  alias SupermarketCashier.Product

  describe "get_product/1" do
    test "returns the product when the code exists" do
      assert %Product{code: "GR1", name: "Green Tea", price: 3.11} = Product.get_product("GR1")
      assert %Product{code: "SR1", name: "Strawberries", price: 5.00} = Product.get_product("SR1")
      assert %Product{code: "CF1", name: "Coffee", price: 11.23} = Product.get_product("CF1")
    end

    test "returns nil when the code does not exist" do
      assert nil == Product.get_product("INVALID")
    end
  end

  describe "all/0" do
    test "returns all products" do
      products = Product.all()
      assert length(products) == 3
      assert %Product{code: "GR1", name: "Green Tea", price: 3.11} in products
      assert %Product{code: "SR1", name: "Strawberries", price: 5.00} in products
      assert %Product{code: "CF1", name: "Coffee", price: 11.23} in products
    end
  end
end
