# frozen_string_literal: true

require "abi_coder_rb"
module Safe
  class Protocol
    include AbiCoderRb
    attr_reader :safe_api, :signer, :chain_id, :safe_address

    def initialize(signer:, chain_id:, safe_address:, rpc:)
      @signer = signer
      @chain_id = chain_id
      @safe_address = safe_address
      @safe_api = TransactionServiceApi.new(chain_id:, safe_address:)
      @contract = Contract.new(safe_address:, rpc:)
    end

    # Creates a consolidated transaction for all given individual transactions
    def create_transaction(txs)
      data = "0x#{encode_multi_send_data(txs)}"
      encoded_data = Util.encode_function_data(function_name: "multiSend", abi: "bytes", data: data)

      transaction = build_transaction(encoded_data)
      tx_hash = Eip712.build(transaction, @chain_id, @safe_address)
      signature = Util.adjust_v_in_signature(@signer.personal_sign(tx_hash))

      @safe_api.multisig_transaction(
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
      )
    end

    def build_transaction(encoded_data)
      puts "nonce #{@contract.nonce}"
      {
        to: "0x998739BFdAAdde7C933B942a68053933098f9EDa",
        value: 0,
        data: encoded_data,
        operation: 1,
        baseGas: 0,
        gasPrice: 0,
        gasToken: "0x0000000000000000000000000000000000000000",
        refundReceiver: "0x0000000000000000000000000000000000000000",
        nonce: @contract.nonce,
        safeTxGas: 0,
      }
    end

    # Encodes multiple transactions for multi-send purposes
    def encode_multi_send_data(txs)
      txs.map { |tx| encode_meta_transaction(tx) }.join
    end

    # Encode a meta transaction
    def encode_meta_transaction(tx)
      types = ["uint8", "address", "uint256", "uint256", "bytes"]
      values = [tx[:operation], tx[:to], tx[:value], tx[:data].bytesize, tx[:data]]
      bin_data = encode(types, values, true)
      Eth::Util.bin_to_hex(bin_data)
    end
  end
end
