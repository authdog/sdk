# frozen_string_literal: true

module Authdog
  class AuthdogError < StandardError; end
  class AuthenticationError < AuthdogError; end
  class ApiError < AuthdogError; end
end
