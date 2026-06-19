# frozen_string_literal: true

require "net/http"
require "json"
require_relative "errors"

module Authdog
  class Client
    def initialize(base_url:, api_key: nil, timeout: 10)
      @base_url = base_url.sub(%r{/+$}, "")
      @api_key = api_key
      @timeout = timeout
    end

    def default_headers
      headers = {
        "Content-Type" => "application/json",
        "User-Agent" => "authdog-ruby-sdk/0.1.0"
      }
      headers["Authorization"] = "Bearer #{@api_key}" if @api_key && !@api_key.empty?
      headers
    end

    def get_userinfo(access_token)
      uri = URI.parse(@base_url + "/v1/userinfo")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.read_timeout = @timeout

      req = Net::HTTP::Get.new(uri.request_uri)
      default_headers.each { |k, v| req[k] = v }
      req["Authorization"] = "Bearer #{access_token}"

      begin
        resp = http.request(req)
        code = resp.code.to_i
        body = resp.body.to_s

        if code == 401
          raise AuthenticationError, "Unauthorized - invalid or expired token"
        end

        if code == 500
          begin
            err = JSON.parse(body)["error"]
            if err == "GraphQL query failed"
              raise ApiError, "GraphQL query failed"
            elsif err == "Failed to fetch user info"
              raise ApiError, "Failed to fetch user info"
            end
          rescue JSON::ParserError
          end
        end

        unless code.between?(200, 299)
          raise ApiError, "HTTP error #{code}: #{body}"
        end

        JSON.parse(body)
      rescue AuthdogError
        raise
      rescue JSON::ParserError => e
        raise ApiError, "Failed to parse response: #{e.message}"
      rescue StandardError => e
        raise ApiError, "Request failed: #{e.message}"
      end
    end
  end
end
