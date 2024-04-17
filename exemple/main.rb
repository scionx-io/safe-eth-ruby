require 'bundler'
Bundler.require
require 'dotenv'
Dotenv.load
require_relative 'util'
require_relative 'transaction_service_api'
require_relative 'protocol'
require_relative 'eip712'
require_relative 'contract'



owner = Eth::Key.new priv: ENV["OWNER_SAFE"]
delegate =  Eth::Key.new priv: ENV["DELEGATE_KEY"]
rpc = "https://eth-sepolia.g.alchemy.com/v2/#{ENV['ALCHEMY_KEY']}"

api = TransactionServiceApi.new(chain_id: 11155111,safe_address: ENV["SAFE_ADDRESS"])

transactions = [
  { operation: 0, to: '0xa89005ab7d7fd81A94c8A8e0799648248CeE6934', value: 1, data: Eth::Util.hex_to_bin("0x") },
  { operation: 0, to: '0xc1b5bcbc94e6127ac3ee4054d0664e4f6afe45d3', value: 1, data: Eth::Util.hex_to_bin("0x") }
]

# 1. if the signer's address is a delegate
delegates = api.get_delegates
response = api.delete_delegate(delegate_address: delegate.address.to_s, owner: owner)
puts response.code


response = api.add_delegate(label: 'Signer Delegate', delegate_address: delegate.address.to_s, owner: owner)
puts response.code

#2 createTransaction


# Preparing data for sending to the contract
protocol = Protocol.new(signer: delegate, chain_id: 11155111, safe_address: ENV["SAFE_ADDRESS"], rpc: rpc)

response = protocol.create_transaction(transactions)
puts response.code



