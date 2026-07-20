class Admin::BaseController < ApplicationController
  before_action :require_authentication

  inertia_share do
    { current_user: current_user.as_json(only: [:id, :username, :email]) }
  end

  private

  def current_user
    @current_user ||= User.find(session[:user_id])
  end

  def require_authentication
    redirect_to admin_sign_in_path unless session[:user_id]
  end
end
