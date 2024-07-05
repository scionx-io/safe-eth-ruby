# frozen_string_literal: true

require "test_helper"
# rubocop:disable Layout/LineLength
class UtilTest < Minitest::Test
  def setup
    @transactions = [
      { operation: 0, to: "0xa89005ab7d7fd81A94c8A8e0799648248CeE6934", value: 1, data: Eth::Util.hex_to_bin("0x") },
      { operation: 0, to: "0xc1b5bcbc94e6127ac3ee4054d0664e4f6afe45d3", value: 1, data: Eth::Util.hex_to_bin("0x") },
    ]
  end

  def test_encode_meta_transaction
    expected_encoded_data = "00a89005ab7d7fd81a94c8a8e0799648248cee693400000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000"
    actual_encoded_data = SafeEthRuby::Util.encode_meta_transaction(@transactions.first)
    assert_equal(expected_encoded_data, actual_encoded_data)
  end

  def test_encode_multi_send_data
    expected_encoded_data = "0x00a89005ab7d7fd81a94c8a8e0799648248cee69340000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000c1b5bcbc94e6127ac3ee4054d0664e4f6afe45d300000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000"
    actual_encoded_data = SafeEthRuby::Util.encode_multi_send_data(@transactions)
    assert_equal(expected_encoded_data, actual_encoded_data)
  end

  def test_adjust_v_in_signature
    expected = "928ba0ef3474a4f705dc27dd6414534be95b7053da3155fa4c35a78a3d34724f242ff7f77f54e118cc333b35e37878192a230b8fdf9be2239a94666ad87a37ca1f"
    signature = "928ba0ef3474a4f705dc27dd6414534be95b7053da3155fa4c35a78a3d34724f242ff7f77f54e118cc333b35e37878192a230b8fdf9be2239a94666ad87a37ca1b"

    actual =  SafeEthRuby::Util.adjust_v_in_signature(signature)
    assert_equal(expected, actual)
  end
end
# rubocop:enable Layout/LineLength
