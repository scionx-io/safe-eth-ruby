# frozen_string_literal: true

module Safe
  module Util
    class << self
      # Slices a hex string to extract a specific byte range
      def slice_hex(value, start_byte = 0, end_byte = nil)
        start_index = start_byte * 2
        end_index = end_byte.nil? ? value.length : end_byte * 2
        value[start_index...end_index]
      end

      # Encodes function call data for smart contract interactions
      def encode_function_data(function_name:, abi:, data:)
        # Generate the function signature hash
        hash = Eth::Util.keccak256("#{function_name}(#{abi})")
        hash = Eth::Util.bin_to_hex(hash)

        # Slice the hash to get the function selector (first 4 bytes)
        signature = slice_hex(hash, 0, 4)

        # Encode the data
        encoded_data = Eth::Util.bin_to_hex(Eth::Abi.encode([abi], [Eth::Util.hex_to_bin(data)]))
        "0x#{signature}#{encoded_data}"
      end

      # Adjusts the V value in an Ethereum signature
      # Adjusts the V value in an Ethereum signature by setting it to 32
      # More info:
      # https://github.com/q9f/eth.rb/blob/db8becdf8f3c8df743425c23462227e8d873b507/lib/eth/key.rb#L85
      # https://github.com/safe-global/safe-core-sdk/blob/afd53e86b9bfe20b8c916ca8ea66ac320b57137c/packages/protocol-kit/src/utils/signatures/utils.ts#L74
      def adjust_v_in_signature(signature)
        # Extract the V value from the last 2 chars of the signature and set it to '20' in hexadecimal (32 decimal)
        signature[0...-2] + 32.to_s(16)
      end
    end
  end
end
