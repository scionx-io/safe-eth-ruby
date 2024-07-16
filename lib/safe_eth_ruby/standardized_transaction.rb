# frozen_string_literal: true

module SafeEthRuby
  class StandardizedTransaction
    attr_reader :signatures, :data

    def initialize(transaction)
      @signatures = extract_signatures(transaction)
      @data = extract_transaction_data(transaction)
    end

    private

    def extract_signatures(transaction)
      transaction["confirmations"].map do |confirmation|
        {
          signer: confirmation["owner"],
          data: confirmation["signature"],
        }
      end
    end

    def extract_transaction_data(transaction)
      {
        to: transaction["to"],
        value: transaction["value"],
        data: Eth::Util.hex_to_bin(transaction["data"]),
        operation: transaction["operation"],
        base_gas: transaction["baseGas"],
        gas_price: transaction["gasPrice"],
        gas_token: transaction["gasToken"],
        refund_receiver: transaction["refundReceiver"],
        nonce: transaction["nonce"],
        safe_tx_gas: transaction["safeTxGas"],
      }
    end
  end
end
