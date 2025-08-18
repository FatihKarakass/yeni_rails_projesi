# frozen_string_literal: true

module XPublisher
  class Client
    def initialize(x_account:)
      @x_account = x_account
      @client = Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV["X_CONSUMER_KEY"]        || Rails.application.credentials.dig(:x, :consumer_key)
        config.consumer_secret     = ENV["X_CONSUMER_SECRET"]     || Rails.application.credentials.dig(:x, :consumer_secret)
        config.access_token        = @x_account.token
        config.access_token_secret = @x_account.secret
      end
    end

    def post(text)
      @client.update(text)
    end
  end
end
