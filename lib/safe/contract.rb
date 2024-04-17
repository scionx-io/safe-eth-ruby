# frozen_string_literal: true

require "eth"

module Safe
  class Contract
    attr_reader :client, :safe_contract

    def initialize(safe_address:, rpc:)
      @client = Eth::Client.create(rpc)
      @safe_contract = Eth::Contract.from_abi(
        name: "SafeContract",
        address: safe_address,
        abi: Safe::ABI::PROXY,
      )
    end

    # Fetch nonce from the contract
    def nonce
      @client.call(@safe_contract, "nonce")
    rescue StandardError => e
      warn("Error fetching nonce: #{e.message}")
    end
  end
end
