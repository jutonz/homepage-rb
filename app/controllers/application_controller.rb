class ApplicationController < ActionController::Base
  include WardenHelper

  rescue_from WardenHelper::UnauthenticatedError do
    session[:return_to] = request.fullpath
    redirect_to new_session_path
  end
end
