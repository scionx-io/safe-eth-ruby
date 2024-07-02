# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module SafeEthRuby
  class TransactionServiceApi
    attr_reader :safe_address, :base_url

    def initialize(chain_id:, safe_address: nil)
      url = SafeEthRuby.get_url(chain_id) || raise(ArgumentError, "Invalid network")
      @safe_address = safe_address
      @base_url = "#{url}/api/"
    end

    def delegates(safe: nil, delegate: nil, delegator: nil, label: nil, limit: nil, offset: nil)
      base_path = "v2/delegates/"
      params = method(__method__).parameters.map do |_, name|
        value = binding.local_variable_get(name)
        [name, value] if value
      end.compact.to_h

      query_string = URI.encode_www_form(params) unless params.empty?
      path = "#{base_path}?#{query_string}"

      get(path)
    end

    def add_delegate(safe:, label:, delegate:, delegator:, signature:)
      post("v2/delegates/", {
        safe:,
        delegate:,
        delegator:,
        label:,
        signature:,
      })
    end

    def delete_delegate(delegate_address:, owner:)
      signature = sign_data(delegate_address, owner)
      delete("v1/delegates/#{delegate_address}/", {
        delegate: delegate_address,
        delegator: owner.address.to_s,
        signature: signature,
      })
    end

    def multisig_transaction(transaction)
      post("v1/safes/#{@safe_address}/multisig-transactions/", transaction)
    end

    def safes(address:)
      get("v1/owners/#{address}/safes/")
    end

    private

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
