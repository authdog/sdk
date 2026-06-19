# frozen_string_literal: true

require 'spec_helper'
require_relative "../lib/authdog"

RSpec.describe Authdog::Client do
  let(:base_url) { "https://api.authdog.com" }
  let(:client) { described_class.new(base_url: base_url) }

  it "retrieves userinfo successfully" do
    stub_request(:get, "#{base_url}/v1/userinfo")
      .with(headers: {"Authorization" => "Bearer token"})
      .to_return(status: 200, body: {meta: {code: 200, message: "OK"}, session: {remainingSeconds: 3600}, user: {id: "123"}}.to_json, headers: {"Content-Type" => "application/json"})

    resp = client.get_userinfo("token")
    expect(resp["user"]["id"]).to eq("123")
  end

  it "raises AuthenticationError on 401" do
    stub_request(:get, "#{base_url}/v1/userinfo").to_return(status: 401, body: "")
    expect { client.get_userinfo("bad") }.to raise_error(Authdog::AuthenticationError)
  end

  it "raises ApiError on GraphQL error" do
    stub_request(:get, "#{base_url}/v1/userinfo").to_return(status: 500, body: {error: "GraphQL query failed"}.to_json)
    expect { client.get_userinfo("t") }.to raise_error(Authdog::ApiError, /GraphQL query failed/)
  end

  it "raises ApiError on fetch error" do
    stub_request(:get, "#{base_url}/v1/userinfo").to_return(status: 500, body: {error: "Failed to fetch user info"}.to_json)
    expect { client.get_userinfo("t") }.to raise_error(Authdog::ApiError, /Failed to fetch user info/)
  end

  it "raises ApiError on other HTTP errors" do
    stub_request(:get, "#{base_url}/v1/userinfo").to_return(status: 400, body: "Bad")
    expect { client.get_userinfo("t") }.to raise_error(Authdog::ApiError, /HTTP error 400/)
  end
end
