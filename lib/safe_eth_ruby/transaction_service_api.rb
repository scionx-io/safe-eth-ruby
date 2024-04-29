# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module SafeEthRuby
  class TransactionServiceApi
    VERSION = "v1/"
    attr_reader :safe_address, :base_url

    def initialize(chain_id:, safe_address:)
      (@network = network_name(chain_id)) || raise(ArgumentError, "Invalid network")
      @base_url = "https://safe-transaction-#{@network}.safe.global/api/#{VERSION}"
      @safe_address = safe_address
    end

    def delegates
      response = get("delegates/?safe=#{@safe_address}")
      return response unless response[:error]

      response[:data]["results"]
    end

    def add_delegate(label:, delegate_address:, owner:)
      signature = sign_data(delegate_address, owner)
      post("delegates/", {
        safe: @safe_address,
        delegate: delegate_address,
        delegator: owner.address.to_s,
        label: label,
        signature: signature,
      })
    end

    def delete_delegate(delegate_address:, owner:)
      signature = sign_data(delegate_address, owner)
      delete("delegates/#{delegate_address}/", {
        delegate: delegate_address,
        delegator: owner.address.to_s,
        signature: signature,
      })
    end

    def multisig_transaction(transaction)
      post("safes/#{@safe_address}/multisig-transactions/", transaction)
    end

    private

    def network_name(chain_id)
      Eth::Chain.constants.find do |const_name|
        return const_name.to_s.downcase if Eth::Chain.const_get(const_name) == chain_id
      end
    end

    def sign_data(delegate_address, owner)
      totp = Time.now.to_i / 3600
      data_to_sign = "#{delegate_address}#{totp}"
      owner.personal_sign(data_to_sign)
    end

    def get(endpoint)
      request(Net::HTTP::Get, endpoint)
    end

    def post(endpoint, payload)
      request(Net::HTTP::Post, endpoint, payload)
    end

    def delete(endpoint, payload = nil)
      request(Net::HTTP::Delete, endpoint, payload)
    end

    def request(http_method_class, endpoint, payload = nil)
      uri = URI("#{@base_url}#{endpoint}")
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        request = http_method_class.new(uri, "Content-Type" => "application/json", "Accept" => "application/json")
        request.body = payload.to_json if payload
        response = http.request(request)
        handle_response_error(response)
      end
    end

    def handle_response_error(response)
      json_response = begin
        JSON.parse(response.body)
      rescue
        {}
      end
      code = response.code.to_i
      if response.is_a?(Net::HTTPSuccess)
        json_response.merge({ code: code })
      else
        error_message = json_response.values_at(
          "message",
          "detail",
          "data",
          "nonFieldErrors",
          "delegate",
          "safe",
          "delegator",
        ).compact.first || response.message
        { error: error_message, code: code }
      end
    end
  end
end
