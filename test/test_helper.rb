ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "jwt"
require "securerandom"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    setup do
      Rails.cache.clear
    end

    def valid_jwt_for(user)
      user.update!(jti: SecureRandom.uuid) unless user.jti.present?
      payload = { user_id: user.id, jti: user.jti, exp: 24.hours.from_now.to_i }
      JWT.encode(payload, Rails.application.secret_key_base)
    end

    def auth_headers_for(user)
      { "Authorization" => "Bearer #{valid_jwt_for(user)}" }
    end

    def api_key_headers_for(user)
      { "Authorization" => "Bearer #{user.api_key}" }
    end
  end
end
