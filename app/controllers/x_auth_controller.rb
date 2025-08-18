class XAuthController < ApplicationController
  require 'net/http'
  require 'json'

  def login
    # CSRF koruması için state parametresi oluştur
    state = SecureRandom.hex(16)
    session[:oauth_state] = state
    
    # PKCE için code verifier oluştur ve sakla
    code_verifier = SecureRandom.urlsafe_base64(32)
    code_challenge = Base64.urlsafe_encode64(Digest::SHA256.digest(code_verifier)).chomp('=')
    session[:code_verifier] = code_verifier
    
    # X OAuth authorization URL'ine yönlendir
    redirect_to XOauth.authorization_url(state: state, code_challenge: code_challenge), allow_other_host: true
  end

  def callback
    # State parametresini doğrula (CSRF koruması)
    if params[:state] != session[:oauth_state]
      redirect_to sign_in_path, alert: "Güvenlik hatası! Lütfen tekrar deneyin."
      return
    end

    # Authorization code'u al
    code = params[:code]
    
    if code.blank?
      redirect_to sign_in_path, alert: "X ile giriş başarısız!"
      return
    end

    begin
      # Access token al
      access_token = get_access_token(code)
      
      # Kullanıcı bilgilerini al
      user_data = get_user_info(access_token)
      
      # Kullanıcıyı bul veya oluştur ve XAccount ekle
      user = find_or_create_user_with_x_account(user_data, access_token)
      
      if user&.persisted?
        # Giriş yap
        session[:user_id] = user.id
        redirect_to root_path, notice: "X ile giriş başarılı! Hoş geldiniz #{user.display_name}!"
      else
        redirect_to sign_in_path, alert: "Kullanıcı oluşturulamadı!" 
      end
      
    rescue => e
      Rails.logger.error "X OAuth Error: #{e.message}"
      redirect_to sign_in_path, alert: "X ile giriş sırasında hata oluştu!"
    ensure
      # OAuth verilerini temizle
      session.delete(:oauth_state)
      session.delete(:code_verifier)
    end
  end

  private

  def get_access_token(code)
    uri = URI(XOauth.token_url)
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    
    # Basic Auth header for X OAuth 2.0
    credentials = Base64.strict_encode64("#{XOauth.client_id}:#{XOauth.client_secret}")
    request['Authorization'] = "Basic #{credentials}"
    
    # X OAuth 2.0 token request body
    request.body = URI.encode_www_form({
      'grant_type' => 'authorization_code',
      'code' => code,
      'redirect_uri' => XOauth.redirect_uri,
      'code_verifier' => session[:code_verifier] || 'rails_x_oauth_challenge' # PKCE için
    })
    
    response = http.request(request)
    
    if response.code.to_i == 200
      token_data = JSON.parse(response.body)
      token_data['access_token']
    else
      Rails.logger.error "Token Error Response: #{response.code} - #{response.body}"
      raise "Token alınamadı: #{response.body}"
    end
  end

  def get_user_info(access_token)
    uri = URI(XOauth.user_info_url)
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{access_token}"
    
    response = http.request(request)
    
    if response.code.to_i == 200
      user_response = JSON.parse(response.body)
      user_response['data'] # X API v2 formatı
    else
      raise "Kullanıcı bilgileri alınamadı: #{response.body}"
    end
  end

  def find_or_create_user_with_x_account(user_data, access_token)
    x_id = user_data['id']
    username = user_data['username']
    name = user_data['name']
    profile_image = user_data['profile_image_url']
    
    # Mevcut kullanıcıyı X ID'si ile bul
    user = User.find_by(x_id: x_id)
    
    if user
      # Kullanıcı bilgilerini güncelle
      user.update(
        x_username: username,
        x_name: name,
        x_profile_image_url: profile_image
      )
      
      # XAccount'u bul veya oluştur
      x_account = user.x_accounts.find_or_create_by(username: username) do |account|
        account.name = name
        account.image = profile_image
        account.token = access_token
      end
      
      # Mevcut XAccount'u güncelle
      x_account.update(
        name: name,
        image: profile_image,
        token: access_token
      )
    else
      # Yeni kullanıcı oluştur
      user = User.create(
        email: "#{username}@x.temp", # Geçici email
        password: SecureRandom.hex(16), # Rastgele şifre
        x_id: x_id,
        x_username: username,
        x_name: name,
        x_profile_image_url: profile_image
      )
      
      # XAccount oluştur
      if user.persisted?
        user.x_accounts.create(
          name: name,
          username: username,
          image: profile_image,
          token: access_token
        )
      end
    end
    
    user
  end
end
