defmodule SupermarketCashier.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, name: SupermarketCashier.CheckoutSupervisor, strategy: :one_for_one}
    ]

    opts = [strategy: :one_for_one, name: SupermarketCashier.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
