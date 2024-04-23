# frozen_string_literal: true

module Safe
  class TransactionServiceApi
    VERSION = "v1/"
    attr_reader :safe_address

    def initialize(chain_id:, safe_address:)
      network = network_name(chain_id)
      raise ArgumentError, "Invalid network" unless network

      @base_url = "https://safe-transaction-#{network}.safe.global/api/#{VERSION}"
      @safe_address = safe_address
    end

    def network_name(chain_id)
      Eth::Chain.constants.find do |const_name|
        return const_name.to_s.downcase if Eth::Chain.const_get(const_name) == chain_id
      end
      nil
    end

    def delegates
      response = get("delegates/?safe=#{@safe_address}")
      JSON.parse(response.body)["results"]
    end

    def add_delegate(label:, delegate_address:, owner:)
      totp = Time.now.to_i / 3600
      data_to_sign = "#{delegate_address}#{totp}"
      puts "owner #{owner.address}"
      signature = owner.personal_sign(data_to_sign)

      post("delegates/", {
        safe: @safe_address,
        delegate: delegate_address,
        delegator: owner.address.to_s,
        label: label,
        signature: signature,
      })
    end

    def delete_delegate(delegate_address:, owner:)
      totp = Time.now.to_i / 3600
      data_to_sign = "#{delegate_address}#{totp}"
      signature = owner.personal_sign(data_to_sign)

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

    def delete(endpoint, payload = nil)
      uri = URI("#{@base_url}#{endpoint}")
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        request = Net::HTTP::Delete.new(uri, "Content-Type" => "application/json")
        request.body = payload.to_json if payload
        http.request(request)
      end
    end

    def get(endpoint)
      Net::HTTP.get_response(URI("#{@base_url}#{endpoint}"))
    end

    def post(endpoint, payload)
      uri = URI("#{@base_url}#{endpoint}")
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
        request.body = payload.to_json
        http.request(request)
      end
    end
  end
end
