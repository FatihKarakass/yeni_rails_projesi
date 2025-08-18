class XAccountsController < ApplicationController
  before_action :require_user_logged_in!
  
  def index
    @x_accounts = Current.user.x_accounts
  end

  def show
    @x_account = Current.user.x_accounts.find(params[:id])
  end

  def edit
    @x_account = Current.user.x_accounts.find(params[:id])
  end

  def update
    @x_account = Current.user.x_accounts.find(params[:id])
    if @x_account.update(x_account_params)
      redirect_to @x_account, notice: "X hesabı başarıyla güncellendi."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @x_account = Current.user.x_accounts.find(params[:id])
    @x_account.destroy
    redirect_to x_accounts_path, notice: "X hesabı başarıyla silindi."
  end

  private

  def x_account_params
    params.require(:x_account).permit(:name, :username, :image)
  end
end
