class ApplicationController < ActionController::Base
  include WardenHelper
  include Pundit::Authorization

  rescue_from WardenHelper::UnauthenticatedError do
    session[:return_to] = request.fullpath
    redirect_to new_session_path
  end

  rescue_from Pundit::NotAuthorizedError do
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

  private

  def pundit_user
    current_user
  end
end
