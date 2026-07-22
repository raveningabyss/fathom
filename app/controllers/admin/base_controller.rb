class Admin::BaseController < ApplicationController
  before_action :require_authentication
  before_action :set_current_user

  inertia_share do
    { current_user: Current.user.as_json(only: [:id, :username, :email]) }
  end

  private

  def set_current_user
    Current.user = User.find(session[:user_id])
  end

  def require_authentication
    redirect_to admin_sign_in_path unless session[:user_id]
  end
end
