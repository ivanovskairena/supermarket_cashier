defmodule SupermarketCashier.CheckoutSupervisor do
  @moduledoc """
  A `DynamicSupervisor` responsible for supervising checkout processes.

  This supervisor dynamically starts and supervises `SupermarketCashier.Checkout`
  processes. Each checkout process can handle a different set of pricing rules.

  ## Example

      iex> {:ok, _sup} = SupermarketCashier.CheckoutSupervisor.start_link()
      iex> {:ok, pid} = SupermarketCashier.CheckoutSupervisor.checkout!([{SupermarketCashier.PricingRules.BuyOneGetOneFree, :apply}])
      iex> is_pid(pid)
      true

  The supervisor ensures that each checkout process is properly supervised and restarted
  if it crashes.
  """

  use DynamicSupervisor

  @doc """
  Starts the `SupermarketCashier.CheckoutSupervisor` supervisor.

  ## Options

    * `:name` - The name to register the supervisor under (optional).

  ## Examples

      iex> {:ok, _sup} = SupermarketCashier.CheckoutSupervisor.start_link()
  """
  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, __MODULE__))
  end

  @doc """
  Starts a new checkout process with the given pricing rules.

  This function validates the provided pricing rules before starting a new `SupermarketCashier.Checkout`
  process under the supervisor. If the pricing rules are valid, it starts the checkout process;
  otherwise, it returns an error.

  ## Parameters

    * `pricing_rules` - A list of tuples where each tuple consists of a module and a function.

  ## Examples

      iex> {:ok, pid} = SupermarketCashier.CheckoutSupervisor.checkout!([{SupermarketCashier.PricingRules.BuyOneGetOneFree, :apply}])
      iex> is_pid(pid)
      true

      iex> SupermarketCashier.CheckoutSupervisor.checkout!([:invalid_rule])
      {:error, :invalid_pricing_rules}
  """
  def checkout!(pricing_rules) when is_list(pricing_rules) do
    if Enum.all?(pricing_rules, &valid_pricing_rule?/1) do
      DynamicSupervisor.start_child(__MODULE__, {SupermarketCashier.Checkout, pricing_rules})
    else
      {:error, :invalid_pricing_rules}
    end
  end

  # Handles invalid pricing rules.
  # This function returns an error if the provided pricing rules are not in the expected format.

  ## Examples

  ##    iex> SupermarketCashier.CheckoutSupervisor.checkout!("invalid")
  ##   {:error, :invalid_pricing_rules}

  def checkout!(_invalid) do
    {:error, :invalid_pricing_rules}
  end

  @doc """
  Validates a single pricing rule.

  A valid pricing rule is a tuple consisting of a module and a function.

  ## Parameters

    * `rule` - A tuple representing a pricing rule.

  ## Examples

      iex> SupermarketCashier.CheckoutSupervisor.valid_pricing_rule?({SupermarketCashier.PricingRules.BuyOneGetOneFree, :apply})
      true

      iex> SupermarketCashier.CheckoutSupervisor.valid_pricing_rule?(:invalid_rule)
      false
  """
  def valid_pricing_rule?({module, function}) when is_atom(module) and is_atom(function),
    do: true

  def valid_pricing_rule?(_), do: false

  @impl true
  @doc """
  Initializes the supervisor with a one-for-one strategy.

  This strategy ensures that if a checkout process crashes, only that process is restarted.
  """
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
