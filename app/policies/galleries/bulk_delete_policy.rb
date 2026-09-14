# typed: strict

module Galleries
  class BulkDeletePolicy < ApplicationPolicy
    Record = type_member { {fixed: Galleries::BulkDelete} }

    sig { returns(T.nilable(T::Boolean)) }
    def create?
      user_owns_gallery?
    end

    private

    sig { returns(T.nilable(T::Boolean)) }
    def user_owns_gallery?
      gallery = T.let(record.gallery, T.nilable(Gallery))
      return false unless gallery

      user && gallery.user == user
    end
  end
end
