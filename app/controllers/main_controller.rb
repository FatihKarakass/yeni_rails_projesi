class MainController < ApplicationController
  def index
    if session[:user_id]
      @user = User.find_by(id: session[:user_id])
    end
    
    flash.now[:notice] = "Hoşgeldiniz! Rails uygulamasına başarıyla erişildi."
  end
end