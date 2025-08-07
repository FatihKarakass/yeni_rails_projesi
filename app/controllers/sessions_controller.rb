class SessionsController < ApplicationController
    def new
     if session[:user_id]
        @user = User.find_by(id: session[:user_id])
        redirect_to root_path, notice: "Logged out"
     end  
end