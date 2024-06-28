defmodule SupermarketCashier.CheckoutSupervisor do
  @moduledoc """
  DynamicSupervisor to supervise checkouts.
  """
  use DynamicSupervisor

  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, __MODULE__))
  end

  def checkout!(pricing_rules) when is_list(pricing_rules) do
    if Enum.all?(pricing_rules, &valid_pricing_rule?/1) do
      DynamicSupervisor.start_child(__MODULE__, {SupermarketCashier.Checkout, pricing_rules})
    else
      {:error, :invalid_pricing_rules}
    end
  end

  def checkout!(_invalid) do
    {:error, :invalid_pricing_rules}
  end

  def valid_pricing_rule?({module, function}) when is_atom(module) and is_atom(function),
    do: true

  def valid_pricing_rule?(_), do: false

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
