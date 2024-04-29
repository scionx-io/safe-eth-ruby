# frozen_string_literal: true

module Safe
  module Util
    class << self
      include AbiCoderRb

      # Slices a hex string to extract a specific byte range
      def slice_hex(value, start_byte = 0, end_byte = nil)
        start_index = start_byte * 2
        end_index = end_byte.nil? ? value.length : end_byte * 2
        value[start_index...end_index]
      end

      # Adjusts the V value in an Ethereum signature
      # More info:
      # https://github.com/q9f/eth.rb/blob/db8becdf8f3c8df743425c23462227e8d873b507/lib/eth/key.rb#L85
      # https://github.com/safe-global/safe-core-sdk/blob/afd53e86b9bfe20b8c916ca8ea66ac320b57137c/packages/protocol-kit/src/utils/signatures/utils.ts#L74
      def adjust_v_in_signature(signature)
        # We expect the V value to be '1c', '1d', '1e', or '1f' and want to set it to '1f'
        signature[-2..].to_i(16)
        new_v = 0x1f # Explicitly setting V to '1f'

        # Convert new V back to hexadecimal and ensure it's two characters long
        new_v_hex = new_v.to_s(16).rjust(2, "0")

        # Replace the last two characters (original V) with the new V value
        signature[0...-2] + new_v_hex
      end

      def encode_multi_send_data(txs)
        "0x" + txs.map { |tx| encode_meta_transaction(tx) }.join
      end

      def encode_meta_transaction(tx)
        types = ["uint8", "address", "uint256", "uint256", "bytes"]
        values = [tx[:operation], tx[:to], tx[:value], tx[:data].bytesize, tx[:data]]
        bin_data = encode(types, values, true)
        Eth::Util.bin_to_hex(bin_data)
      end

      # Encodes function call data for smart contract interactions
      def encode_function_data(function_name:, abi:, data:)
        # Generate the function signature hash
        hash = Eth::Util.keccak256("#{function_name}(#{abi})")
        signature = slice_hex(Eth::Util.bin_to_hex(hash), 0, 4)

        # Encode the data
        encoded_data = Eth::Util.bin_to_hex(Eth::Abi.encode([abi], [Eth::Util.hex_to_bin(data)]))
        "0x#{signature}#{encoded_data}"
      end
    end
  end
end
