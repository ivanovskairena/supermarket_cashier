defmodule SupermarketCashier.ProductTest do
  use ExUnit.Case
  alias SupermarketCashier.Product

  describe "get_product/1" do
    test "returns the product when the code exists" do
      assert %Product{code: "GR1", name: "Green Tea", price: 3.11} = Product.get_product("GR1")
    end

    test "returns nil when the code does not exist" do
      assert nil == Product.get_product("INVALID")
    end
  end
end
