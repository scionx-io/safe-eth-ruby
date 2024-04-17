# frozen_string_literal: true

module Safe
  module Eip712
    class << self
      def build(transaction, chain_id, verifying_contract)
        typed_data = {
          types: {
            EIP712Domain: [
              { name: "chainId", type: "uint256" },
              { name: "verifyingContract", type: "address" },
            ],
            SafeTx: [
              { type: "address", name: "to" },
              { type: "uint256", name: "value" },
              { type: "bytes", name: "data" },
              { type: "uint8", name: "operation" },
              { type: "uint256", name: "safeTxGas" },
              { type: "uint256", name: "baseGas" },
              { type: "uint256", name: "gasPrice" },
              { type: "address", name: "gasToken" },
              { type: "address", name: "refundReceiver" },
              { type: "uint256", name: "nonce" },
            ],
          },
          domain: {
            verifyingContract: verifying_contract,
            chainId: chain_id,
          },
          primaryType: "SafeTx",
          message: transaction,
        }

        Eth::Eip712.hash(typed_data)
      end
    end
  end
end
