defmodule SupermarketCashier.ProductTest do
  use ExUnit.Case
  alias SupermarketCashier.Product
  import Decimal, only: [from_float: 1, compare: 2]

  describe "get_product/1" do
    test "returns the product when the code exists" do
      product = Product.get_product("GR1")
      assert %Product{code: "GR1", name: "Green Tea"} = product
      assert compare(product.price, from_float(3.11)) == :eq

      product = Product.get_product("SR1")
      assert %Product{code: "SR1", name: "Strawberries"} = product
      assert compare(product.price, from_float(5.00)) == :eq

      product = Product.get_product("CF1")
      assert %Product{code: "CF1", name: "Coffee"} = product
      assert compare(product.price, from_float(11.23)) == :eq
    end

    test "returns nil when the code does not exist" do
      assert nil == Product.get_product("INVALID")
    end
  end

  describe "all/0" do
    test "returns all products" do
      products = Product.all()
      assert length(products) == 3

      green_tea = %Product{code: "GR1", name: "Green Tea", price: from_float(3.11)}
      strawberries = %Product{code: "SR1", name: "Strawberries", price: from_float(5.00)}
      coffee = %Product{code: "CF1", name: "Coffee", price: from_float(11.23)}

      assert Enum.any?(products, fn product -> compare(product.price, green_tea.price) == :eq end)

      assert Enum.any?(products, fn product ->
               compare(product.price, strawberries.price) == :eq
             end)

      assert Enum.any?(products, fn product -> compare(product.price, coffee.price) == :eq end)
    end
  end
end
