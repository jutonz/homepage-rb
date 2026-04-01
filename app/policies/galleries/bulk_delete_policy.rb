module Galleries
  class BulkDeletePolicy < ApplicationPolicy
    def create?
      user_owns_gallery?
    end

    private

    def user_owns_gallery?
      return false unless record.gallery

      user && record.gallery.user == user
    end
  end
end
