class MainController < ApplicationController
  def index
    if session[:user_id]
      @user = User.find_by(id: session[:user_id])
      @x_accounts = @user.x_accounts if @user
    end

    flash.now[:notice] = "Hoşgeldiniz! Rails uygulamasına başarıyla erişildi."
  end
end
