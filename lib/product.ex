defmodule SupermarketCashier.Product do
  @moduledoc """
  Provides functions to fetch product details and defines the Product struct.
  """

  defstruct code: "", name: "", price: 0.0

  @type t() :: %__MODULE__{
          code: String.t(),
          name: String.t(),
          price: float()
        }

  @doc "Returns all products known to the system"
  @spec all() :: [t()]
  def all(), do: products()

  @doc "Finds a product by its code"
  @spec get_product(String.t()) :: t() | nil
  def get_product(code), do: Enum.find(products(), &(&1.code == code))

  defp products do
    [
      %__MODULE__{code: "GR1", name: "Green Tea", price: 3.11},
      %__MODULE__{code: "SR1", name: "Strawberries", price: 5.00},
      %__MODULE__{code: "CF1", name: "Coffee", price: 11.23}
    ]
  end
end
