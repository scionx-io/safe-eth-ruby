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

  # rubocop:disable Layout/LineLength
  def test_decode_data
    data = "0x8d80ff0a000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000001cb001c7d4b196cb0c7b01d743fbc6116a902379c723800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044a9059cbb000000000000000000000000a89005ab7d7fd81a94c8a8e0799648248cee693400000000000000000000000000000000000000000000000000000000000f4240001c7d4b196cb0c7b01d743fbc6116a902379c723800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044a9059cbb000000000000000000000000c1b5bcbc94e6127ac3ee4054d0664e4f6afe45d300000000000000000000000000000000000000000000000000000000000f4240001c7d4b196cb0c7b01d743fbc6116a902379c723800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044a9059cbb00000000000000000000000048f945aafb38658243d38eeb89538e879fba47810000000000000000000000000000000000000000000000000000000000004e20000000000000000000000000000000000000000000"

    response = @api.decode_data(
      data: data,
      to: "0x998739BFdAAdde7C933B942a68053933098f9EDa",
    )

    assert_kind_of(Hash, response)
    assert_equal("multiSend", response["method"])
    assert_kind_of(Array, response["parameters"])
    refute_empty(response["parameters"])
  end
  # rubocop:enable Layout/LineLength
end
