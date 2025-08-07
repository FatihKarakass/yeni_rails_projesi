class MainController < ApplicationController
  def index
    # Ana sayfa için basit bir welcome mesajı
    flash.now[:notice] = "Hoşgeldiniz! Rails uygulamasına başarıyla erişildi."
  end
end