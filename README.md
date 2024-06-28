# SupermarketCashier

This project implements a simple cashier function for a small supermarket chain. The cashier function allows adding products to a cart and displaying the total price. It is designed with flexibility to accommodate frequently changing pricing rules.

## Requirements

1. Programming Language: Elixir
2. Methodology: Test-Driven Development (TDD)
3. Repository: GitHub (public)
4. Database: Not required

## Product Details
The following test products are registered in the system:

Product Code	Name	        Price
----------------------------------
GR1	          Green tea	    £3.11
SR1	          Strawberries	£5.00
CF1	          Coffee	      £11.23

## Special Conditions
1. Green Tea (GR1): Buy-one-get-one-free offer.
2. Strawberries (SR1): Price drops to £4.50 per strawberry if 3 or more are purchased.
3. Coffee (CF1): Price drops to two-thirds of the original price if 3 or more are purchased.

## Test Data
The checkout system can scan items in any order. Below are some test cases:

### Basket: GR1, SR1, GR1, GR1, CF1

Total Price Expected: £22.45

### Basket: GR1, GR1

Total Price Expected: £3.11

### Basket: SR1, SR1, GR1, SR1

Total Price Expected: £16.61

### Basket: GR1, CF1, SR1, CF1, CF1

Total Price Expected: £30.57

# Setup and Installation

1. Clone the repository:

``` elixir 
git clone https://github.com/ivanovskairena/supermarket_cashier.git
cd supermarket_cashier
```

2. Install dependencies:

``` elixir
mix deps.get
```

3. Run tests:
``` elixir
mix test
```

4. Run credo and dialyzer checks 
``` elixir 
mix credo

mix dialyzer
```

5. Generate test coverage report
``` elixir 
mix coveralls.html
```

# Usage in IEx
To interact with the SupermarketCashier module in IEx, follow these steps:


## Test Individual Scans

1. Start IEx session

Navigate to your project directory and start an IEx session with Mix:

``` elixir
iex -S mix
```

2. Define pricing rules:

``` elixir
pricing_rules = [
  {SupermarketCashier.PricingRules.BuyOneGetOneFree, :apply_rule},
  {SupermarketCashier.PricingRules.BulkDiscount, :apply_rule},
  {SupermarketCashier.PricingRules.MultiDiscount, :apply_rule}
]
```

3. Start the Checkout process
``` elixir 
{:ok, pid} = SupermarketCashier.Checkout.new(pricing_rules)
```

3. Test individual scans:

``` elixir
SupermarketCashier.Checkout.scan(pid, "GR1")
IO.puts("Total after scanning GR1: #{SupermarketCashier.Checkout.total(pid)}")

SupermarketCashier.Checkout.scan(pid, "SR1")
IO.puts("Total after scanning SR1: #{SupermarketCashier.Checkout.total(pid)}")

SupermarketCashier.Checkout.scan(pid, "GR1")
IO.puts("Total after scanning GR1: #{SupermarketCashier.Checkout.total(pid)}")

SupermarketCashier.Checkout.scan(pid, "GR1")
IO.puts("Total after scanning GR1: #{SupermarketCashier.Checkout.total(pid)}")

SupermarketCashier.Checkout.scan(pid, "CF1")
IO.puts("Total after scanning CF1: #{SupermarketCashier.Checkout.total(pid)}")

SupermarketCashier.Checkout.total(pid)
IO.puts("Total: #{total}")

``` 

## Test with a basket of items

1. Start IEx session

Navigate to your project directory and start an IEx session with Mix:

``` elixir
iex -S mix
```

2. Alias the BasketScan Helper
``` elixir 
alias SupermarketCashier.BasketScan
```
3. Define pricing rules:

``` elixir
pricing_rules = [
  {SupermarketCashier.PricingRules.BuyOneGetOneFree, :apply_rule},
  {SupermarketCashier.PricingRules.BulkDiscount, :apply_rule},
  {SupermarketCashier.PricingRules.MultiDiscount, :apply_rule}
]
```

4. Start the Checkout process
``` elixir 
{:ok, pid} = SupermarketCashier.Checkout.new(pricing_rules)
```

5. Add Items to the Basket

``` elixir 
items = ["GR1", "SR1", "GR1", "GR1", "CF1"]
```

6. Test the result
``` elixir
total = BasketScan.test_basket(pricing_rules, items)
IO.puts("Total: #{total}")
```
