require 'test_helper'

class ProtocolTest < Minitest::Test
  def setup
    @delegate = Eth::Key.new priv: ENV["DELEGATE_KEY"]
    @rpc = "https://eth-sepolia.g.alchemy.com/v2/#{ENV['ALCHEMY_KEY']}"
    @protocol = Safe::Protocol.new(signer: @delegate, chain_id: 11_155_111,
                                   safe_address: '0x8739A1EcCD57B38c270070E89dc25958AAb6b750', rpc: @rpc)
    @transactions = [
      { operation: 0, to: '0xa89005ab7d7fd81A94c8A8e0799648248CeE6934', value: 1, data: Eth::Util.hex_to_bin('0x') },
      { operation: 0, to: '0xc1b5bcbc94e6127ac3ee4054d0664e4f6afe45d3', value: 1, data: Eth::Util.hex_to_bin('0x') }
    ]
  end

  def test_create_transaction
    response = @protocol.create_transaction(@transactions)
    assert_equal("201", response.code)
  end
end