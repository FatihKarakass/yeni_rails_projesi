class XAuthController < ApplicationController
  require 'net/http'
  require 'json'

  def login
    # CSRF koruması için state parametresi oluştur
    state = SecureRandom.hex(16)
    
    # X OAuth authorization URL'ine yönlendir
    redirect_to XOauth.authorization_url(state: state), allow_other_host: true
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
      
      # Kullanıcıyı bul veya oluştur
      user = find_or_create_user(user_data)
      
      if user&.persisted?
        # Giriş yap
        session[:user_id] = user.id
        redirect_to root_path, notice: "X ile giriş başarılı! Hoş geldiniz #{user.x_name}!"
      else
        redirect_to sign_in_path, alert: "Kullanıcı oluşturulamadı!"
      end
      
    rescue => e
      Rails.logger.error "X OAuth Error: #{e.message}"
      redirect_to sign_in_path, alert: "X ile giriş sırasında hata oluştu!"
    ensure
      # State'i temizle
      session.delete(:oauth_state)
    end
  end

  private

  def get_access_token(code)
    uri = URI(XOauth.token_url)
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    
    # X OAuth 2.0 token request
    request.body = URI.encode_www_form({
      'grant_type' => 'authorization_code',
      'client_id' => XOauth.client_id,
      'client_secret' => XOauth.client_secret,
      'code' => code,
      'redirect_uri' => XOauth.redirect_uri,
      'code_verifier' => 'rails_x_oauth_challenge' # PKCE için
    })
    
    response = http.request(request)
    
    if response.code.to_i == 200
      token_data = JSON.parse(response.body)
      token_data['access_token']
    else
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

  def find_or_create_user(user_data)
    x_id = user_data['id']
    
    # Mevcut kullanıcıyı X ID'si ile bul
    user = User.find_by(x_id: x_id)
    
    if user
      # Kullanıcı bilgilerini güncelle
      user.update(
        x_username: user_data['username'],
        x_name: user_data['name'],
        x_profile_image_url: user_data['profile_image_url']
      )
    else
      # Yeni kullanıcı oluştur
      user = User.create(
        email: "#{user_data['username']}@x.temp", # Geçici email
        password: SecureRandom.hex(16), # Rastgele şifre
        x_id: x_id,
        x_username: user_data['username'],
        x_name: user_data['name'],
        x_profile_image_url: user_data['profile_image_url']
      )
    end
    
    user
  end
end
