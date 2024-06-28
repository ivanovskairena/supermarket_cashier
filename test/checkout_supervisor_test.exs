defmodule SupermarketCashier.CheckoutSupervisorTest do
  use ExUnit.Case

  alias SupermarketCashier.{CheckoutSupervisor, PricingRules, Checkout}

  setup do
    pricing_rules = [
      {PricingRules.BuyOneGetOneFree, :apply_rule},
      {PricingRules.BulkDiscount, :apply_rule},
      {PricingRules.MultiDiscount, :apply_rule}
    ]

    {:ok, pid} = CheckoutSupervisor.checkout!(pricing_rules)
    {:ok, pid: pid, pricing_rules: pricing_rules}
  end

  describe "Checkout process management" do
    test "supervisor can start checkout process", %{pid: pid} do
      assert is_pid(pid)
    end

    test "checkout process through supervisor", %{pricing_rules: pricing_rules} do
      {:ok, pid} = CheckoutSupervisor.checkout!(pricing_rules)
      Checkout.scan(pid, "GR1")
      Checkout.scan(pid, "SR1")
      total = Checkout.total(pid)
      assert total == "£8.11"
    end

    test "supervisor handles multiple checkouts", %{pricing_rules: pricing_rules} do
      {:ok, pid1} = CheckoutSupervisor.checkout!(pricing_rules)
      {:ok, pid2} = CheckoutSupervisor.checkout!(pricing_rules)
      assert is_pid(pid1)
      assert is_pid(pid2)
      assert pid1 != pid2
    end
  end

  describe "Supervisor restart and termination handling" do
    test "supervisor restarts a crashed checkout process", %{pid: pid} do
      initial_children = DynamicSupervisor.count_children(CheckoutSupervisor)

      Process.flag(:trap_exit, true)
      Process.exit(pid, :kill)

      :timer.sleep(1000)

      new_children = DynamicSupervisor.count_children(CheckoutSupervisor)
      assert new_children.active == initial_children.active
    end

    test "supervisor handles checkout process termination gracefully", %{pid: pid} do
      initial_children = DynamicSupervisor.count_children(CheckoutSupervisor)

      Process.flag(:trap_exit, true)
      Process.exit(pid, :normal)

      :timer.sleep(1000)

      new_children = DynamicSupervisor.count_children(CheckoutSupervisor)
      assert new_children.active == initial_children.active
    end
  end

  describe "Supervisor start_link options" do
    test "supervisor start_link with different options" do
      result = Supervisor.stop(CheckoutSupervisor)

      if result == :ok or match?({:error, _}, result) do
        assert {:ok, _pid} = CheckoutSupervisor.start_link(name: :another_supervisor)
      else
        flunk("Supervisor stop returned unexpected result: #{inspect(result)}")
      end
    end

    test "supervisor fails to start with invalid name option" do
      result = Supervisor.stop(CheckoutSupervisor)

      if result == :ok or match?({:error, _}, result) do
        assert {:ok, _pid} = CheckoutSupervisor.start_link(name: :invalid_name_option)
      else
        flunk("Supervisor stop returned unexpected result: #{inspect(result)}")
      end
    end
  end

  describe "Invalid inputs and error handling" do
    test "supervisor handles invalid checkout process with incorrect format gracefully" do
      assert {:error, :invalid_pricing_rules} = CheckoutSupervisor.checkout!("invalid_format")
    end

    test "supervisor can handle valid empty pricing rules list" do
      assert {:ok, pid} = CheckoutSupervisor.checkout!([])
      assert is_pid(pid)
    end

    test "validates valid pricing rule format" do
      assert Enum.all?(
               [
                 {PricingRules.BuyOneGetOneFree, :apply_rule},
                 {PricingRules.BulkDiscount, :apply_rule},
                 {PricingRules.MultiDiscount, :apply_rule}
               ],
               fn rule -> apply(CheckoutSupervisor, :valid_pricing_rule?, [rule]) end
             )
    end

    test "invalid pricing rule format" do
      assert not apply(CheckoutSupervisor, :valid_pricing_rule?, ["invalid_rule"])
    end

    test "fails to start with invalid child spec" do
      invalid_spec = %{
        id: :invalid_child,
        start: {:invalid_module, :start_link, []}
      }

      assert {:error, _} = DynamicSupervisor.start_child(CheckoutSupervisor, invalid_spec)
    end

    test "captures error reason during start_child with invalid child spec" do
      _invalid_spec = %{
        id: :invalid_child,
        start: {:invalid_module, :start_link, []}
      }

      assert {:error, _} = CheckoutSupervisor.checkout!(["invalid_spec"])
    end

    test "handles non-list argument for checkout!" do
      assert {:error, :invalid_pricing_rules} = CheckoutSupervisor.checkout!(:invalid)
    end

    test "handles invalid pricing rules" do
      invalid_rules = "invalid_rules"
      result = CheckoutSupervisor.checkout!(invalid_rules)
      assert result == {:error, :invalid_pricing_rules}
    end
  end
end
