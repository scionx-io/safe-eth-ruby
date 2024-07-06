# frozen_string_literal: true

module SafeEthRuby
  module Util
    class << self
      include AbiCoderRb

      ETHEREUM_V_VALUES = [0, 1, 27, 28].freeze
      MIN_VALID_V_VALUE_FOR_SAFE_ECDSA = 27

      # Slices a hex string to extract a specific byte range
      def slice_hex(value, start_byte = 0, end_byte = nil)
        start_index = start_byte * 2
        end_index = end_byte.nil? ? value.length : end_byte * 2
        value[start_index...end_index]
      end

      # Adjusts the V value in an Ethereum signature
      def adjust_v_in_signature(signature, signing_method = :eth_sign, safe_tx_hash = nil, signer_address = nil)
        signature_v = signature[-2..].to_i(16)

        raise "Invalid signature" unless ETHEREUM_V_VALUES.include?(signature_v)

        signature_v += MIN_VALID_V_VALUE_FOR_SAFE_ECDSA if signature_v < MIN_VALID_V_VALUE_FOR_SAFE_ECDSA

        if signing_method == :eth_sign
          adjusted_signature = signature[0...-2] + signature_v.to_s(16).rjust(2, "0")
          signature_v += 4 if tx_hash_signed_with_prefix?(safe_tx_hash, adjusted_signature, signer_address)
        end

        signature_v_hex = signature_v.to_s(16).rjust(2, "0")
        signature[0...-2] + signature_v_hex
      end

      def encode_transactions(txs)
        Eth::Util.hex_to_bin("0x" + txs.map { |tx| encode_transaction(tx) }.join)
      end

      def encode_transaction(tx)
        types = ["uint8", "address", "uint256", "uint256", "bytes"]
        values = [tx[:operation], tx[:to], tx[:value], tx[:data].bytesize, tx[:data]]
        bin_data = encode(types, values, true)
        Eth::Util.bin_to_hex(bin_data)
      end

      # Encodes function call data for smart contract interactions
      def encode_function_data(function_name:, abi:, args:)
        hash = Eth::Util.keccak256("#{function_name}(#{abi.join(",")})")
        signature = slice_hex(Eth::Util.bin_to_hex(hash), 0, 4)
        encoded_data = Eth::Util.bin_to_hex(Eth::Abi.encode(abi, args))
        "0x#{signature}#{encoded_data}"
      end

      # Check if a transaction hash is signed with a prefix
      def tx_hash_signed_with_prefix?(tx_hash, signature, owner_address)
        r = [signature[2...66]].pack("H*")
        s = [signature[66...130]].pack("H*")
        v = signature[130...132].to_i(16)
        recovered_data = Eth::Key.personal_recover(tx_hash, Eth::Sig.new(v: v, r: r, s: s))
        recovered_address = Eth::Util.public_key_to_address(recovered_data)
        recovered_address.downcase != owner_address.downcase
      rescue StandardError
        true
      end
    end
  end
end
