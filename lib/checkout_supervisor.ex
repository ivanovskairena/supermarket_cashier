defmodule SupermarketCashier.CheckoutSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: SupermarketCashier.CheckoutSupervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def start_checkout(supervisor) do
    DynamicSupervisor.start_child(supervisor, {SupermarketCashier.Checkout, []})
  end
end
