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
    actual_encoded_data = Safe::Util.encode_meta_transaction(@transactions.first)
    assert_equal(expected_encoded_data, actual_encoded_data)
  end

  def test_encode_multi_send_data
    expected_encoded_data = "0x00a89005ab7d7fd81a94c8a8e0799648248cee69340000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000c1b5bcbc94e6127ac3ee4054d0664e4f6afe45d300000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000"
    actual_encoded_data = Safe::Util.encode_multi_send_data(@transactions)
    assert_equal(expected_encoded_data, actual_encoded_data)
  end

  def test_adjust_v_in_signature
    expected = "a067eeb07384cbe54a82a4716909f124a80d2f9cad4ef2dd8ca106ac25541fcd79740950d9338a0bce1cc15145aac565ff08f98c3f9640a1496d191956c4b7bb1f"
    signature = "a067eeb07384cbe54a82a4716909f124a80d2f9cad4ef2dd8ca106ac25541fcd79740950d9338a0bce1cc15145aac565ff08f98c3f9640a1496d191956c4b7bb20"

    actual =  Safe::Util.adjust_v_in_signature(signature)
    assert_equal(expected, actual)
  end
end
# rubocop:enable Layout/LineLength
