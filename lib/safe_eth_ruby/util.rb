# frozen_string_literal: true

module SafeEthRuby
  module Util
    class << self
      include AbiCoderRb

      ETHEREUM_V_VALUES = [0, 1, 27, 28].freeze
      MIN_VALID_V_VALUE_FOR_SAFE_ECDSA = 27
      SIGNATURE_LENGTH_BYTES = 65

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

      def build_signature(signatures)
        signatures.sort_by! { |sig| sig[:signer].downcase }

        signature_bytes = "0x"
        dynamic_bytes = ""

        signatures.each do |sig|
          if sig[:dynamic]
            dynamic_bytes_length = dynamic_bytes.length / 2
            position = signatures.length * SIGNATURE_LENGTH_BYTES + dynamic_bytes_length
            dynamic_part_position = position.to_s(16).rjust(64, "0")

            data_length = sig[:data][2..-1].length / 2
            dynamic_part_length = data_length.to_s(16).rjust(64, "0")

            signer_part = sig[:signer][2..-1].rjust(64, "0")
            static_signature = "#{signer_part}#{dynamic_part_position}00"

            dynamic_part_with_length = "#{dynamic_part_length}#{sig[:data][2..-1]}"

            signature_bytes += static_signature
            dynamic_bytes += dynamic_part_with_length
          else
            signature_bytes += sig[:data][2..-1]
          end
        end

        Eth::Util.hex_to_bin(signature_bytes + dynamic_bytes)
      end
    end
  end
end
