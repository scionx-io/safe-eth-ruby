# frozen_string_literal: true

require "test_helper"

class TransactionServiceApiTest < Minitest::Test
  def setup
    @api = SafeEthRuby::TransactionServiceApi.new(chain_id: 11155111)
  end

  def test_safes
    response = @api.safes(owner: "0x48F945aafB38658243d38eEb89538e879fba4781")
    assert_kind_of(Array, response["safes"])
    refute_empty(response["safes"])
  end

  def test_delegates
    response = @api.delegates(options: { safe: "0x8739A1EcCD57B38c270070E89dc25958AAb6b750" })
    assert_kind_of(Array, response["results"])
    refute_empty(response["results"])
  end

  def test_get_transactions
    response = @api.get_transactions(address: "0x48F945aafB38658243d38eEb89538e879fba4781", options: {})
    assert_kind_of(Array, response["results"])
  end

  def test_pending_transactions
    response = @api.pending_transactions(address: "0x48F945aafB38658243d38eEb89538e879fba4781")
    assert_kind_of(Array, response["results"])
  end

  def test_safe
    response = @api.safe(address: "0x48F945aafB38658243d38eEb89538e879fba4781")
    assert_kind_of(Hash, response)
    refute_empty(response)
  end
end
