# frozen_string_literal: true

require "test_helper"

class TransactionServiceApiTest < Minitest::Test
  def setup
    @api = SafeEthRuby::TransactionServiceApi.new(chain_id: 11155111)
  end

  def test_safes
    response = @api.safes(address: "0x48F945aafB38658243d38eEb89538e879fba4781")
    assert_kind_of(Array, response["safes"])
    refute_empty(response["safes"])
  end

  def test_delegates
    response = @api.delegates(safe: "0x8739A1EcCD57B38c270070E89dc25958AAb6b750")
    assert_kind_of(Array, response["results"])
    refute_empty(response["results"])
  end

  # def test_delegate_addition
  # response = @api.add_delegate(label: "Signer Delegate", delegate_address: @owner.address, owner: @owner)
  # assert_equal("201", response.code)

  # response = @api.delete_delegate(delegate_address: @owner.address, owner: @owner)
  # assert_equal("204", response.code)
  # end
end
