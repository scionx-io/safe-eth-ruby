# frozen_string_literal: true

require "test_helper"

class TransactionServiceApiTest < Minitest::Test
  def setup
    @api = Safe::TransactionServiceApi.new(
      chain_id: 11_155_111,
      safe_address: "0x8739A1EcCD57B38c270070E89dc25958AAb6b750",
    )
    @owner = Eth::Key.new(priv: ENV["OWNER_SAFE"])
  end

  def test_delegate_addition
    response = @api.add_delegate(label: "Signer Delegate", delegate_address: @owner.address, owner: @owner)
    puts response.body
    assert_equal("201", response.code)

    response = @api.delete_delegate(delegate_address: @owner.address, owner: @owner)
    puts response.body
   
    assert_equal("204", response.code)
  end
end
