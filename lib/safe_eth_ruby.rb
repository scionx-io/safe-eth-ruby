# frozen_string_literal: true

module SafeEthRuby
end

# Loads the {Safe} module classes.
require_relative "safe_eth_ruby/transaction_service_api"
require_relative "safe_eth_ruby/protocol"
require_relative "safe_eth_ruby/contract"
require_relative "safe_eth_ruby/util"
require_relative "safe_eth_ruby/eip712"
require_relative "safe_eth_ruby/abi/proxy"

