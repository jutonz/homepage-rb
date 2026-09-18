# typed: strict

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    sig { void }
    def connect
      self.current_user = find_verified_user
    end

    private

    sig { returns(User) }
    def find_verified_user
      user = request.env["warden"]&.user
      user || reject_unauthorized_connection
    end
  end
end
