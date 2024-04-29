# SafeEthRubyGem

Welcome to SafeEthRubyGem! This gem provides functionality to interact with Ethereum smart contracts safely using Ruby.

## Installation

To install the gem, add it to your Gemfile:

```sh
$ bundle add safe_eth_ruby
```

## Usage

```ruby
require "safe_eth_ruby"

owner = Eth::Key.new(priv: ENV["OWNER_SAFE"])
delegate = Eth::Key.new(priv: ENV["DELEGATE_KEY"])
rpc = "https://eth-sepolia.g.alchemy.com/v2/#{ENV["ALCHEMY_KEY"]}"

api = SafeEthRuby::TransactionServiceApi.new(chain_id: 11155111, safe_address: ENV["SAFE_ADDRESS"])

transactions = [
  { operation: 0, to: "0x", value: 1, data: Eth::Util.hex_to_bin("0x") },
  { operation: 0, to: "0x", value: 1, data: Eth::Util.hex_to_bin("0x") },
]
```
#### 1. if the signer's address is a delegate
```ruby
api.delegates
response = api.delete_delegate(delegate_address: delegate.address.to_s, owner:)

response = api.add_delegate(label: "Signer Delegate", delegate_address: delegate.address.to_s, owner:)
```

#### 2. createTransaction
```ruby
protocol = SafeEthRuby::Protocol.new(signer: delegate, chain_id: 11155111, safe_address: ENV["SAFE_ADDRESS"], rpc:)

response = protocol.create_transaction(transactions)
```

## Development

1. Clone the repository.
2. Run `bin/setup` to install dependencies.
3. Run `rake test` to run the tests.
4. Use `bin/console` for an interactive prompt to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version:

1. Update the version number in `version.rb`.
2. Run `bundle exec rake release`.
3. This will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [RubyGems](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/[USERNAME]/safe_eth_ruby_gem).
