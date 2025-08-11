module Galleries
  class BulkUploadPolicy < ApplicationPolicy
    def new?
      user_owns_gallery?
    end

    def create?
      user_owns_gallery?
    end

    private

    def user_owns_gallery?
      return false unless record.gallery

      record.gallery.user == user
    end
  end
end
