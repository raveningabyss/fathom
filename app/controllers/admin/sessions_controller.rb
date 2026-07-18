class Admin::SessionsController < ApplicationController
  before_action :redirect_if_authenticated

  def new
  end

  def create
    user = User.find_by(email: params[:identity])
    user ||= User.find_by(username: params[:identity])
    if user&.authenticate(params[:password])
      # Clear old session to prevent session fixation attack
      reset_session

      session[:user_id] = user.id
      redirect_to admin_root_path
    else
      render inertia: 'admin/sessions/New',
             props: { errors: { identity: "Invalid email or password." } },
             status: :unauthorized
    end
  end

  def destroy
    reset_session
    redirect_to admin_root_path
  end

  private

  def redirect_if_authenticated
    redirect_to admin_root_path if session[:user_id]
  end
end
