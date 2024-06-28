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
  def init(order) do
    {:ok, order}
  end

  @impl true
  def handle_call(:order, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:total, _from, state) do
    case apply_pricing_rules(state) do
      {:ok, total_with_rules} ->
        {:reply, format_price(total_with_rules), state}

      {:error, _reason} ->
        {:reply, "Error occurred in pricing rules", state}
    end
  end

  @impl true
  def handle_call(:checkout, _from, state) do
    case apply_pricing_rules(state) do
      {:ok, total_with_rules} ->
        {:stop, :normal, format_price(total_with_rules), %Order{}}

      {:error, _reason} ->
        {:stop, :normal, "Error occurred in pricing rules", %Order{}}
    end
  end

  @impl true
  def handle_cast({:scan, nil}, state), do: {:noreply, state}

  @impl true
  def handle_cast({:scan, product}, %Order{items: items} = state) do
    {:noreply, %Order{state | items: [product | items]}}
  end

  defp apply_pricing_rules(%Order{items: items, pricing_rules: pricing_rules}) do
    total = Enum.reduce(items, 0.0, &(&1.price + &2))

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

    * `total` - The total amount to be formatted.

  ## Examples

      iex> SupermarketCashier.Checkout.format_price(3.11)
      "£3.11"
  """
  def format_price(total) do
    rounded_total = Float.round(total, 2)

    :io_lib.format("£~.2f", [rounded_total])
    |> IO.iodata_to_binary()
  end
end
