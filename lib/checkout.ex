defmodule SupermarketCashier.Checkout do
  @moduledoc """
  A `GenServer` responsible for handling the checkout process.

  This module provides functions to start a new checkout process, scan items,
  calculate the total price, and complete the checkout. It applies various
  pricing rules to the items in the cart and formats the total price with a currency symbol.

  ## Example

      iex> {:ok, pid} = SupermarketCashier.Checkout.new(pricing_rules)
      iex> SupermarketCashier.Checkout.scan(pid, "GR1")
      :ok
      iex> SupermarketCashier.Checkout.total(pid)
      "£3.11"
      iex> SupermarketCashier.Checkout.checkout(pid)
      "£3.11"
  """

  use GenServer, restart: :transient
  require Logger
  import Decimal, only: [round: 3, from_float: 1, to_string: 2]

  alias SupermarketCashier.{Order, Product}

  @doc """
  Starts a new checkout process.

  ## Parameters

    * `pricing_rules` - A list of pricing rules to be applied during the checkout.

  ## Examples

      iex> {:ok, pid} = SupermarketCashier.Checkout.start_link(pricing_rules)
  """
  def start_link(pricing_rules) do
    GenServer.start_link(__MODULE__, %Order{pricing_rules: pricing_rules})
  end

  @doc """
  Creates a new checkout process.

  ## Parameters

    * `pricing_rules` - A list of pricing rules to be applied during the checkout.

  ## Examples

      iex> {:ok, pid} = SupermarketCashier.Checkout.new(pricing_rules)
  """
  def new(pricing_rules), do: start_link(pricing_rules)

  @doc """
  Returns the current order state of the checkout process.

  ## Parameters

    * `pid` - The process identifier of the checkout process.

  ## Examples

      iex> order = SupermarketCashier.Checkout.order(pid)
      %SupermarketCashier.Order{...}
  """
  @spec order(pid()) :: Order.t()
  def order(pid), do: GenServer.call(pid, :order)

  @doc """
  Scans an item and adds it to the cart.

  ## Parameters

    * `pid` - The process identifier of the checkout process.
    * `product_code` - The code of the product to scan.

  ## Examples

      iex> SupermarketCashier.Checkout.scan(pid, "GR1")
      :ok
  """
  @spec scan(pid(), String.t()) :: :ok | {:error, String.t()}
  def scan(pid, product_code) do
    case Product.get_product(product_code) do
      nil ->
        Logger.warning("Product not found: #{product_code}")
        {:error, "Product not found"}

      product ->
        GenServer.cast(pid, {:scan, product})
        :ok
    end
  end

  @doc """
  Returns the total price formatted with the currency symbol.

  ## Parameters

    * `pid` - The process identifier of the checkout process.

  ## Examples

      iex> SupermarketCashier.Checkout.total(pid)
      "£3.11"
  """
  @spec total(pid()) :: String.t()
  def total(pid), do: GenServer.call(pid, :total)

  @doc """
  Returns the total price formatted with the currency symbol and terminates the process.

  ## Parameters

    * `pid` - The process identifier of the checkout process.

  ## Examples

      iex> SupermarketCashier.Checkout.checkout(pid)
      "£3.11"
  """
  @spec checkout(pid()) :: String.t()
  def checkout(pid), do: GenServer.call(pid, :checkout)

  @impl true
  @doc false
  def init(order) do
    {:ok, order}
  end

  @impl true
  @doc false
  def handle_call(:order, _from, state) do
    {:reply, state, state}
  end

  @impl true
  @doc false
  def handle_call(:total, _from, state) do
    case apply_pricing_rules(state) do
      {:ok, total_with_rules} ->
        {:reply, format_price(total_with_rules), state}

      {:error, _reason} ->
        {:reply, "Error occurred in pricing rules", state}
    end
  end

  @impl true
  @doc false
  def handle_call(:checkout, _from, state) do
    case apply_pricing_rules(state) do
      {:ok, total_with_rules} ->
        {:stop, :normal, format_price(total_with_rules), %Order{}}

      {:error, _reason} ->
        {:stop, :normal, "Error occurred in pricing rules", %Order{}}
    end
  end

  @impl true
  @doc false
  def handle_cast({:scan, nil}, state), do: {:noreply, state}

  @impl true
  @doc false
  def handle_cast({:scan, product}, %Order{items: items} = state) do
    {:noreply, %Order{state | items: [product | items]}}
  end

  # Applies pricing rules to the items in the order and calculates the total price.

  ## Parameters

  # * `order` - The order containing the items and pricing rules.

  ## Examples

  #    iex> apply_pricing_rules(%Order{items: [%Product{code: "GR1", price: Decimal.new("3.11")}], pricing_rules: []})
  #    {:ok, Decimal.new("3.11")}

  defp apply_pricing_rules(%Order{items: items, pricing_rules: pricing_rules}) do
    total = calculate_total(items)
    apply_rules(pricing_rules, items, total)
  end

  # Calculates the total price of the items.

  ## Parameters

  #  * `items` - A list of items to calculate the total price for.

  ## Examples

  #    iex> calculate_total([%Product{code: "GR1", price: Decimal.new("3.11")}])
  #    Decimal.new("3.11")

  defp calculate_total(items) do
    Enum.reduce(items, Decimal.new("0.0"), fn item, acc ->
      price = normalize_price(item.price)
      Decimal.add(acc, price)
    end)
  end

  @doc """
  Normalizes the price to a Decimal format.

  ## Parameters

    * `price` - The price to normalize.

  ## Examples

      iex> normalize_price(3.11)
      Decimal.from_float(3.11)

      iex> normalize_price(3)
      Decimal.new(3)

      iex> normalize_price(Decimal.new("3.11"))
      Decimal.new("3.11")

      iex> normalize_price("invalid")
      ** (ArgumentError) Invalid price format
  """
  def normalize_price(price) do
    cond do
      is_float(price) -> from_float(price)
      is_integer(price) -> Decimal.new(price)
      match?(%Decimal{}, price) -> price
      true -> raise ArgumentError, "Invalid price format"
    end
  end

  # Applies the pricing rules to the items and calculates the total price.

  ## Parameters

  # * `pricing_rules` - A list of pricing rules to apply.
  # * `items` - A list of items to apply the pricing rules to.
  # * `total` - The initial total price before applying the pricing rules.

  ## Examples

  # iex> apply_rules([], [%Product{code: "GR1", price: Decimal.new("3.11")}], Decimal.new("3.11"))
  # {:ok, Decimal.new("3.11")}

  defp apply_rules(pricing_rules, items, total) do
    Enum.reduce(pricing_rules, {:ok, total}, fn rule, {:ok, acc} ->
      try do
        case rule do
          {module, function} when is_atom(module) and is_atom(function) ->
            {:ok, apply(module, function, [items, acc])}

          function when is_function(function, 2) ->
            {:ok, function.(items, acc)}

          _ ->
            raise ArgumentError, "Invalid pricing rule format"
        end
      catch
        :error, message ->
          Logger.error("Error applying pricing rule: #{Exception.message(message)}")
          {:error, message}
      end
    end)
  end

  @doc """
  Formats the total price with the currency symbol.

  ## Parameters

    * `total` - The total price to format.

  ## Examples

      iex> format_price(Decimal.from_float(3.115))
      "£3.12"

      iex> format_price(Decimal.from_float(3.114))
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
