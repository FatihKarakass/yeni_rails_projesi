# X (Twitter) OAuth 2.0 Configuration
module XOauth
  class << self
    def client_id
      Rails.application.credentials.dig(:x, :client_id) || ENV['X_CLIENT_ID']
    end

    def client_secret
      Rails.application.credentials.dig(:x, :client_secret) || ENV['X_CLIENT_SECRET']
    end

    def redirect_uri
      if Rails.env.production?
        "#{ENV['PRODUCTION_HOST']}/auth/x/callback"
      else
        "http://localhost:3000/auth/x/callback"
      end
    end

    def authorization_url(state:, code_challenge: nil)
      challenge = code_challenge || generate_code_challenge
      "https://x.com/i/oauth2/authorize?" +
        "response_type=code&" +
        "client_id=#{client_id}&" +
        "redirect_uri=#{redirect_uri}&" +
        "scope=tweet.read%20users.read&" +
        "state=#{state}&" +
        "code_challenge=#{challenge}&" +
        "code_challenge_method=S256"
    end

    def token_url
      "https://api.x.com/2/oauth2/token"
    end

    def user_info_url
      "https://api.x.com/2/users/me"
    end

    private

    def generate_code_challenge
      # PKCE için basit bir implementation
      # Gerçek uygulamada daha güvenli olmalı
      Base64.urlsafe_encode64(Digest::SHA256.digest("rails_x_oauth_challenge")).chomp('=')
    end
  end
end
