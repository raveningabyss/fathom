class Admin::BaseController < ApplicationController
  before_action :require_authentication

  private

  def require_authentication
    redirect_to admin_sign_in_path unless session[:user_id]
  end
end
