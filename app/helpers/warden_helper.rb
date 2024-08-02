module WardenHelper
  class UnauthenticatedError < StandardError; end

  def warden = request.env["warden"]

  def current_user = warden.user

  def ensure_authenticated!
    raise UnauthenticatedError unless current_user.present?
  end
end
