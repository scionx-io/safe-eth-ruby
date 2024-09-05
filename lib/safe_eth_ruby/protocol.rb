# frozen_string_literal: true

require "abi_coder_rb"

module SafeEthRuby
  class Protocol
    attr_reader :safe_api, :signer, :chain_id, :safe_address

    def initialize(signer:, chain_id:, safe_address:, rpc:)
      @signer = signer
      @chain_id = chain_id
      @safe_address = safe_address
      @safe_api = TransactionServiceApi.new(chain_id:)
      @safe = SafeEthRuby::Safe.new(safe_address:, rpc:)
    end

    def create_transaction(transactions:, nonce: current_nonce) # Fix the typo here
      transaction_encoded = Util.encode_transactions(transactions)
      encoded_data = Util.encode_function_data(function_name: "multiSend", abi: ["bytes"], args: [transaction_encoded])
      transaction = build_transaction(encoded_data:, nonce:)
      tx_hash = transaction_hash(transaction)
      signature = sign_hash(tx_hash)

      result = @safe_api.multisig_transaction(
        address: @safe_address,
        transaction: {
          to: transaction[:to],
          value: transaction[:value],
          data: transaction[:data],
          operation: transaction[:operation],
          nonce: transaction[:nonce],
          gasToken: transaction[:gasToken],
          baseGas: transaction[:baseGas],
          gasPrice: transaction[:gasPrice],
          safeTxGas: transaction[:safeTxGas],
          refundReceiver: transaction[:refundReceiver],
          contractTransactionHash: "0x#{Eth::Util.bin_to_hex(tx_hash)}",
          sender: @signer.address.to_s,
          signature: "0x#{signature}",
        },
      )
      result.merge({ tx_hash: "0x#{Eth::Util.bin_to_hex(tx_hash)}" })
    end

    def execute_transaction(safe_tx_hash:)
      transaction = @safe_api.transaction(safe_tx_hash:)
      standardized_transaction = StandardizedTransaction.new(transaction)

      @safe.exec_transaction(
        to: standardized_transaction.data[:to],
        value: standardized_transaction.data[:value].to_i,
        data: standardized_transaction.data[:data],
        operation: standardized_transaction.data[:operation].to_i,
        safe_tx_gas: standardized_transaction.data[:safe_tx_gas].to_i,
        base_gas: standardized_transaction.data[:base_gas].to_i,
        gas_price: standardized_transaction.data[:gas_price].to_i,
        gas_token: standardized_transaction.data[:gas_token],
        refund_receiver: standardized_transaction.data[:refund_receiver],
        signatures: Util.build_signature(standardized_transaction.signatures),
        sender_key: @signer,
      )
    end

    def build_transaction(encoded_data:, nonce: current_nonce) # Fix the typo here as well
      {
        to: "0x998739BFdAAdde7C933B942a68053933098f9EDa",
        value: 0,
        data: encoded_data,
        operation: 1,
        baseGas: 0,
        gasPrice: 0,
        gasToken: "0x0000000000000000000000000000000000000000",
        refundReceiver: "0x0000000000000000000000000000000000000000",
        nonce:,
        safeTxGas: 0,
      }
    end

    def transaction_hash(transaction)
      Eip712.build(transaction, @chain_id, @safe_address)
    end

    def sign_hash(tx_hash)
      Util.adjust_v_in_signature(@signer.personal_sign(tx_hash))
    end

    def current_nonce
      @safe.nonce
    end

    def next_nonce
      transactions = @safe_api.pending_transactions(address: @safe_address)
      if transactions["results"].any?
        nonces = transactions["results"].map { |tx| tx["nonce"] }
        nonces.max.to_i + 1
      else
        current_nonce
      end
    end
  end
end
