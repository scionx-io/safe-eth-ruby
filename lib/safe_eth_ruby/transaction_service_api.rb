# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module SafeEthRuby
  class TransactionServiceApi
    attr_reader :safe_address, :base_url

    def initialize(chain_id:)
      url = SafeEthRuby.get_url(chain_id) || raise(ArgumentError, "Invalid network")
      @base_url = "#{url}/api/"
    end

    def delegates(options: {})
      request_with_params("v2/delegates/", options)
    end

    def add_delegate(safe:, label:, delegate:, delegator:, signature:)
      post("v2/delegates/", {
        safe: safe,
        delegate: delegate,
        delegator: delegator,
        label: label,
        signature: signature,
      })
    end

    def delete_delegate(delegate_address:, delegator:, signature:)
      delete("v2/delegates/#{delegate_address}/", {
        delegate: delegate_address,
        delegator: delegator,
        signature: signature,
      })
    end

    def transaction(safe_tx_hash:)
      get("v1/multisig-transactions/#{safe_tx_hash}/")
    end

    def get_transactions(address:, options: {})
      request_with_params("v1/safes/#{address}/multisig-transactions/", options)
    end

    def pending_transactions(address:)
      nonce = safe(address: address)["nonce"]

      get_transactions(address: address, options: {
        nonce__gte: nonce,
        executed: "false",
      })
    end

    def confirmations(safe_tx_hash:, signature:)
      post("v1/multisig-transactions/#{safe_tx_hash}/confirmations/", {
        signature: signature,
      })
    end

    def multisig_transaction(address:, transaction:)
      post("v1/safes/#{address}/multisig-transactions/", transaction)
    end

    def safes(owner:)
      get("v1/owners/#{owner}/safes/")
    end

    def safe(address:)
      get("v1/safes/#{address}/")
    end

    def balances(address:, trusted: false, exclude_spam: false)
      query_params = { trusted: trusted, exclude_spam: exclude_spam }
      request_with_params("v1/safes/#{address}/balances/", query_params)
    end

    def multisig_transactions(address:, options: {})
      request_with_params("v1/safes/#{address}/multisig-transactions/", options)
    end

    def all_transactions(address:, options: {})
      request_with_params("v1/safes/#{address}/all-transactions/", options)
    end

    private

    def request_with_params(endpoint, params)
      query_params = params.compact
      get(build_path(endpoint, query_params))
    end

    def build_path(base_path, params)
      query_string = URI.encode_www_form(params)
      query_string.empty? ? base_path : "#{base_path}?#{query_string}"
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
        # puts request.body
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
      return json_response if response.is_a?(Net::HTTPSuccess) && json_response.is_a?(Array)

      if response.is_a?(Net::HTTPSuccess)
        json_response.merge(code: response.code.to_i)
      else
        {
          errors: json_response,
          code: response.code.to_i,
        }
      end
    end
  end
end
