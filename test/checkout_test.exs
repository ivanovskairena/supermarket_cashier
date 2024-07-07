defmodule SupermarketCashier.CheckoutTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  alias SupermarketCashier.{Checkout, PricingRules, Product}
  import Decimal, only: [from_float: 1, new: 1, sub: 2]

  setup do
    pricing_rules = [
      {PricingRules.BuyOneGetOneFree, :apply_rule},
      {PricingRules.BulkDiscount, :apply_rule},
      {PricingRules.MultiDiscount, :apply_rule}
    ]

    {:ok, pid} = Checkout.new(pricing_rules)
    {:ok, pid: pid}
  end

  defp add_products(pid, product_codes) do
    Enum.each(product_codes, fn code -> Checkout.scan(pid, code) end)
  end

  describe "Total price calculation" do
    test "for basket: GR1, CF1, SR1, CF1, CF1", %{pid: pid} do
      add_products(pid, ["GR1", "CF1", "SR1", "CF1", "CF1"])
      total = Checkout.total(pid)
      assert total == "£30.57"
    end

    test "for basket: GR1, GR1", %{pid: pid} do
      add_products(pid, ["GR1", "GR1"])
      total = Checkout.total(pid)
      assert total == "£3.11"
    end

    test "for basket: SR1, SR1, GR1, SR1", %{pid: pid} do
      add_products(pid, ["SR1", "SR1", "GR1", "SR1"])
      total = Checkout.total(pid)
      assert total == "£16.61"
    end

    test "for basket: GR1, SR1, GR1, GR1, CF1", %{pid: pid} do
      add_products(pid, ["GR1", "SR1", "GR1", "GR1", "CF1"])
      total = Checkout.total(pid)
      assert total == "£22.45"
    end

    test "with pricing rules", %{pid: pid} do
      add_products(pid, ["GR1", "GR1", "SR1"])
      total = Checkout.total(pid)
      assert total == "£8.11"
    end

    test "without items", %{pid: pid} do
      total = Checkout.total(pid)
      assert total == "£0.00"
    end

    test "handles empty items list" do
      {:ok, pid} = Checkout.new([])
      total = Checkout.total(pid)
      assert total == "£0.00"
    end

    test "handles pricing rules with empty items" do
      faulty_rule = fn _, acc -> acc end
      pricing_rules = [faulty_rule]
      {:ok, pid} = Checkout.new(pricing_rules)
      total = Checkout.total(pid)
      assert total == "£0.00"
    end
  end

  describe "Checkout process" do
    test "calculates total and stops the process", %{pid: pid} do
      add_products(pid, ["CF1", "GR1"])
      total = Checkout.checkout(pid)
      assert total == "£14.34"
    end

    test "checkout without items", %{pid: pid} do
      total = Checkout.checkout(pid)
      assert total == "£0.00"
    end
  end

  describe "Scanning products" do
    test "scans non-existent product and logs warning", %{pid: pid} do
      log =
        capture_log(fn ->
          result = Checkout.scan(pid, "INVALID")
          assert result == {:error, "Product not found"}
        end)

      assert log =~ "Product not found: INVALID"
    end

    test "scans nil product and returns error", %{pid: pid} do
      result = Checkout.scan(pid, nil)
      assert result == {:error, "Product not found"}
      total = Checkout.total(pid)
      assert total == "£0.00"
    end

    test "handle_cast for scan with nil product", %{pid: pid} do
      GenServer.cast(pid, {:scan, nil})
      total = Checkout.total(pid)
      assert total == "£0.00"
    end

    test "handle_cast for valid product scan", %{pid: pid} do
      GenServer.cast(
        pid,
        {:scan, %Product{code: "GR1", name: "Green tea", price: new("3.11")}}
      )

      total = Checkout.total(pid)
      assert total == "£3.11"
    end
  end

  describe "Order handling" do
    test "retrieves the order", %{pid: pid} do
      assert %SupermarketCashier.Order{} = Checkout.order(pid)
    end
  end

  describe "Pricing rules" do
    test "bulk discount for exactly 3 strawberries", %{pid: pid} do
      add_products(pid, ["SR1", "SR1", "SR1"])
      total = Checkout.total(pid)
      assert total == "£13.50"
    end

    test "multi discount for exactly 3 coffees", %{pid: pid} do
      add_products(pid, ["CF1", "CF1", "CF1"])
      total = Checkout.total(pid)
      assert total == "£22.46"
    end

    test "applies pricing rules with no rules defined", _context do
      {:ok, pid} = Checkout.new([])
      add_products(pid, ["GR1"])
      total = Checkout.total(pid)
      assert total == "£3.11"
    end

    test "handles empty items list" do
      {:ok, pid} = Checkout.new([])
      total = Checkout.total(pid)
      assert total == "£0.00"
    end

    test "handles pricing rules with empty items" do
      faulty_rule = fn _, acc -> acc end
      pricing_rules = [faulty_rule]
      {:ok, pid} = Checkout.new(pricing_rules)
      total = Checkout.total(pid)
      assert total == "£0.00"
    end
  end

  describe "normalize_price/1" do
    test "converts float to Decimal" do
      assert Checkout.normalize_price(1.23) == Decimal.from_float(1.23)
    end

    test "converts integer to Decimal" do
      assert Checkout.normalize_price(5) == Decimal.new(5)
    end

    test "returns Decimal as is" do
      decimal_price = Decimal.new("3.11")
      assert Checkout.normalize_price(decimal_price) == decimal_price
    end

    test "raises ArgumentError for invalid price format" do
      assert_raise ArgumentError, fn ->
        Checkout.normalize_price("invalid_price")
      end
    end
  end

  describe "Price formatting" do
    test "formats price correctly" do
      assert Checkout.format_price(from_float(3.115)) == "£3.12"
      assert Checkout.format_price(from_float(3.114)) == "£3.11"
      assert Checkout.format_price(from_float(3.1)) == "£3.10"
    end
  end

  describe "Concurrent carts" do
    test "Test Several Carts (concurrent)", _context do
      tasks =
        for _ <- 1..10 do
          Task.async(fn ->
            {:ok, pid} =
              Checkout.new([
                {PricingRules.BuyOneGetOneFree, :apply_rule},
                {PricingRules.BulkDiscount, :apply_rule},
                {PricingRules.MultiDiscount, :apply_rule}
              ])

            Checkout.scan(pid, "GR1")
            Checkout.total(pid)
          end)
        end

      results = Task.await_many(tasks)
      assert Enum.all?(results, fn total -> total == "£3.11" end)
    end
  end

  describe "Error handling in pricing rules" do
    test "handles invalid function format and replies with error message" do
      pricing_rules = [
        "invalid_function"
      ]

      {:ok, pid} = Checkout.new(pricing_rules)
      add_products(pid, ["GR1"])

      log =
        capture_log(fn ->
          total = Checkout.total(pid)
          assert total == "Error occurred in pricing rules"
        end)

      assert log =~ "Error applying pricing rule: Invalid pricing rule format"
    end

    test "handles unexpected error in pricing rule and replies with error message" do
      pricing_rules = [
        fn _, _ -> raise "Unexpected error" end
      ]

      {:ok, pid} = Checkout.new(pricing_rules)
      add_products(pid, ["GR1"])

      log =
        capture_log(fn ->
          total = Checkout.total(pid)
          assert total == "Error occurred in pricing rules"
        end)

      assert log =~ "Error applying pricing rule: Unexpected error"
    end

    test "handles error in pricing rules for checkout" do
      faulty_rule = fn _, _ -> raise "Pricing rule error" end
      {:ok, pid} = Checkout.start_link([faulty_rule])
      assert Checkout.checkout(pid) == "Error occurred in pricing rules"
    end
  end

  describe "Scanning edge cases" do
    test "scans an empty product code", %{pid: pid} do
      result = Checkout.scan(pid, "")
      assert result == {:error, "Product not found"}
      total = Checkout.total(pid)
      assert total == "£0.00"
    end

    test "scans a nil product code", %{pid: pid} do
      result = Checkout.scan(pid, nil)
      assert result == {:error, "Product not found"}
      total = Checkout.total(pid)
      assert total == "£0.00"
    end

    test "scans a valid product code twice", %{pid: pid} do
      result = Checkout.scan(pid, "GR1")
      assert result == :ok
      result = Checkout.scan(pid, "GR1")
      assert result == :ok
      total = Checkout.total(pid)
      assert total == "£3.11"
    end
  end

  describe "apply_pricing_rules function" do
    test "handles valid inline function format" do
      pricing_rules = [
        fn _items, acc -> sub(acc, new("1.0")) end
      ]

      {:ok, pid} = Checkout.new(pricing_rules)
      add_products(pid, ["GR1"])
      total = Checkout.total(pid)
      assert total == "£2.11"
    end

    test "handles invalid function format and replies with error message" do
      pricing_rules = [
        "invalid_function"
      ]

      {:ok, pid} = Checkout.new(pricing_rules)
      add_products(pid, ["GR1"])

      log =
        capture_log(fn ->
          total = Checkout.total(pid)
          assert total == "Error occurred in pricing rules"
        end)

      assert log =~ "Error applying pricing rule: Invalid pricing rule format"
    end

    test "handles unexpected error in pricing rule and replies with error message" do
      pricing_rules = [
        fn _, _ -> raise "Unexpected error" end
      ]

      {:ok, pid} = Checkout.new(pricing_rules)
      add_products(pid, ["GR1"])

      log =
        capture_log(fn ->
          total = Checkout.total(pid)
          assert total == "Error occurred in pricing rules"
        end)

      assert log =~ "Error applying pricing rule: Unexpected error"
    end
  end
end
