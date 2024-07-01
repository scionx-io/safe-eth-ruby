# frozen_string_literal: true

require "test_helper"

class TransactionServiceApiTest < Minitest::Test
  def setup
    @api = SafeEthRuby::TransactionServiceApi.new(
      chain_id: 1,
      safe_address: "0xc1b5Bcbc94E6127aC3ee4054d0664E4f6aFe45d3",
    )
    @owner = Eth::Key.new(priv: ENV["OWNER_SAFE"])
  end

  def test_owners
    response = @api.owners
    assert_equal(200, response[:code])
    assert_kind_of(Array, response["safes"])
    refute_empty(response["safes"])
  end

  # def test_delegate_addition
  # response = @api.add_delegate(label: "Signer Delegate", delegate_address: @owner.address, owner: @owner)
  # assert_equal("201", response.code)

  # response = @api.delete_delegate(delegate_address: @owner.address, owner: @owner)
  # assert_equal("204", response.code)
  # end
end
