defmodule SupermarketCashier.Checkout do
  use GenServer, restart: :transient
  require Logger
  alias SupermarketCashier.{Order, Product}

  @doc "Starts a new checkout process"
  def start_link(pricing_rules) do
    GenServer.start_link(__MODULE__, %Order{pricing_rules: pricing_rules})
  end

  def new(pricing_rules), do: start_link(pricing_rules)

  @doc "Returns the order behind this process"
  @spec order(pid()) :: Order.t()
  def order(pid), do: GenServer.call(pid, :order)

  @doc "Scans the item in the cart, given product code"
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

  @doc "Returns total, formatted with currency symbol, does not kill itself"
  @spec total(pid()) :: String.t()
  def total(pid), do: GenServer.call(pid, :total)

  @doc "Returns total, formatted with currency symbol, kills itself"
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

  def format_price(total) do
    rounded_total = Float.round(total, 2)

    :io_lib.format("£~.2f", [rounded_total])
    |> IO.iodata_to_binary()
  end
end
