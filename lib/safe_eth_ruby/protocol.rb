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
    end

    # Creates a consolidated transaction for all given individual transactions
    def create_transaction(txs)
      data = Util.encode_multi_send_data(txs)
      encoded_data = Util.encode_function_data(function_name: "multiSend", abi: "bytes", data: data)
      transaction = build_transaction(encoded_data)

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

    def build_transaction(encoded_data)
      {
        to: "0x998739BFdAAdde7C933B942a68053933098f9EDa",
        value: 0,
        data: encoded_data,
        operation: 1,
        baseGas: 0,
        gasPrice: 0,
        gasToken: "0x0000000000000000000000000000000000000000",
        refundReceiver: "0x0000000000000000000000000000000000000000",
        nonce: next_nonce(address: @safe_address),
        safeTxGas: 0,
      }
    end

    def transaction_hash(transaction)
      Eip712.build(transaction, @chain_id, @safe_address)
    end

    def sign_hash(tx_hash)
      Util.adjust_v_in_signature(@signer.personal_sign(tx_hash))
    end

    def currnent_nonce
      @safe_api.safe(address: @safe_address)["nonce"]
    end

    def next_nonce(address:)
      transactions = @safe_api.pending_transactions(address:)
      if transactions["results"].any?
        nonces = transactions["results"].map { |tx| tx["nonce"] }
        nonces.max.to_i + 1
      else
        currnent_nonce
      end
    end
  end
end
