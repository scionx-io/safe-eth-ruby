# frozen_string_literal: true

require "eth"

module SafeEthRuby
  class Safe
    attr_reader :client, :safe_contract

    def initialize(safe_address:, rpc:)
      @client = Eth::Client.create(rpc)
      @safe_contract = Eth::Contract.from_abi(
        name: "SafeContract",
        address: safe_address,
        abi: SafeEthRuby::ABI::PROXY,
      )
    end

    def balance
      @client.get_balance(@safe_contract.address)
    end

    def nonce
      @client.call(@safe_contract, "nonce")
    end

    def hash_approved?(address:, tx_hash:)
      @client.call(@safe_contract, "approvedHashes", address, tx_hash)
    end

    def owners
      @client.call(@safe_contract, "getOwners")
    end

    def threshold
      @client.call(@safe_contract, "getThreshold")
    end
  end
end
