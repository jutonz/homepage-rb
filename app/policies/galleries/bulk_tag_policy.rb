# typed: true

module Galleries
  class BulkTagPolicy < ApplicationPolicy
    Record = type_member { {fixed: Galleries::BulkTag} }

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
