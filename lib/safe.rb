# frozen_string_literal: true

module Safe
end

# Loads the {Safe} module classes.
require "safe/protocol"
require "safe/transaction_service_api"
require "safe/contract"
require "safe/util"
require "safe/eip712"
require "safe/abi/proxy"
