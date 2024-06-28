defmodule SupermarketCashier do
  @moduledoc """
  The SupermarketCashier module provides functionality to add products to a cart and calculate the total price.
  """

  @doc """
  Adds a product to the cart.

  ## Examples

      iex> cart = []
      iex> product = %SupermarketCashier.Product{code: "GR1", name: "Green Tea", price: 3.11}
      iex> SupermarketCashier.add_product(cart, product)
      [%SupermarketCashier.Product{code: "GR1", name: "Green Tea", price: 3.11}]
  """
  def add_product(cart, product) do
    [product | cart]
  end

  @doc """
  Calculates the total price of the cart.

  ## Examples

      iex> cart = [
      ...>   %SupermarketCashier.Product{code: "GR1", name: "Green Tea", price: 3.11},
      ...>   %SupermarketCashier.Product{code: "SR1", name: "Strawberries", price: 5.00}
      ...> ]
      iex> SupermarketCashier.total_price(cart)
      8.11
  """
  def total_price(cart) do
    Enum.reduce(cart, 0.0, fn product, acc -> acc + product.price end)
  end
end
