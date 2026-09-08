# typed: true

module Galleries
  class BulkUploadPolicy < ApplicationPolicy
    Record = type_member { {fixed: Galleries::BulkUpload} }

    def new?
      user_owns_gallery?
    end

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
