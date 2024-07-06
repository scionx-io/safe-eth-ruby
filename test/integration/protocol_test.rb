# frozen_string_literal: true

require "test_helper"

class ProtocolTest < Minitest::Test
  def setup
    @delegate = Eth::Key.new(priv: ENV["DELEGATE2_KEY"])
    @rpc = "https://eth-sepolia.g.alchemy.com/v2/#{ENV["ALCHEMY_KEY"]}"
    @protocol = SafeEthRuby::Protocol.new(
      signer: @delegate,
      chain_id: 11_155_111,
      safe_address: "0x8739A1EcCD57B38c270070E89dc25958AAb6b750",
      rpc: @rpc,
    )
    @transactions = [
      { operation: 0, to: "0xa89005ab7d7fd81A94c8A8e0799648248CeE6934", value: 1, data: Eth::Util.hex_to_bin("0x") },
      { operation: 0, to: "0xc1b5bcbc94e6127ac3ee4054d0664e4f6afe45d3", value: 1, data: Eth::Util.hex_to_bin("0x") },
    ]
  end

  def test_transaction_hash
    expected = "bf5f7a81565b3ee208b55b2c1da87ecffb507748431f46a7225ec83523139be3"
    transaction_encoded = SafeEthRuby::Util.encode_transactions(@transactions)
    encoded_data = SafeEthRuby::Util.encode_function_data(
      function_name: "multiSend",
      abi: ["bytes"],
      args: [transaction_encoded],
    )
    transactions = {
      to: "0x998739BFdAAdde7C933B942a68053933098f9EDa",
      value: 0,
      data: encoded_data,
      operation: 1,
      baseGas: 0,
      gasPrice: 0,
      gasToken: "0x0000000000000000000000000000000000000000",
      refundReceiver: "0x0000000000000000000000000000000000000000",
      nonce: 10,
      safeTxGas: 0,
    }
    actual = Eth::Util.bin_to_hex(@protocol.transaction_hash(transactions))
    assert_equal(expected, actual)
  end

  def test_create_transaction
    response = @protocol.create_transaction(transactions: @transactions)
    assert_equal(201, response[:code], "Expected HTTP 201 Created, but got #{response[:code]}: #{response}")
  end
end
