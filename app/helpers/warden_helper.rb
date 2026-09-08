# typed: true

module WardenHelper
  class UnauthenticatedError < StandardError; end

  def warden = T.unsafe(self).request.env["warden"]

  def current_user = warden.user

  def ensure_authenticated!
    Kernel.raise(UnauthenticatedError) unless current_user.present?
  end
end
