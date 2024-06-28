defmodule SupermarketCashier.Checkout do
  use GenServer

  def start_link(initial_state \\ []) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def init(initial_state) do
    {:ok, initial_state}
  end

  def add_product(pid, product), do: GenServer.call(pid, {:add_product, product})
  def total(pid), do: GenServer.call(pid, :total_price)

  def handle_call({:add_product, product}, _from, state) do
    {:reply, :ok, [product | state]}
  end

  def handle_call(:total_price, _from, state) do
    total = Enum.reduce(state, 0.0, fn product, acc -> acc + product.price end)
    {:reply, total, state}
  end
end
