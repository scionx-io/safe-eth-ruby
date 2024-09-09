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

  def test_transaction
    response = @api.transaction(
      safe_tx_hash: "0xce9f7339edc3be26dee4c9c14d29303f3ad9c9c3f6612322a495df5af983abe0",
    )
    assert_equal(response["safe"], "0x73E0f6f550B3976b1bBDB835967Ebb687f5A2aFA")
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

  def test_balances
    response = @api.balances(address: "0xbA6A6718BfC116ff0252d527cbc8F302182626c8", trusted: false, exclude_spam: false)
    assert_kind_of(Array, response)
    refute_empty(response)
    assert(response.first["balance"])
  end

  def test_multisig_transactions
    response = @api.multisig_transactions(
      address: "0xbA6A6718BfC116ff0252d527cbc8F302182626c8",
      options: { nonce__gte: 0, executed: "false" },
    )

    assert_kind_of(Hash, response)
    assert_kind_of(Array, response["results"])
    if response["results"].empty?
      skip("No transactions returned for the given address and filters.")
    else
      assert(response["results"].first["safe"])
      assert(response["results"].first["nonce"])
    end
  end

  def test_all_transactions
    response = @api.all_transactions(address: "0x48F945aafB38658243d38eEb89538e879fba4781", options: {})
    assert_kind_of(Hash, response)
    assert_kind_of(Array, response["results"])
    refute_empty(response["results"])
  end
end
