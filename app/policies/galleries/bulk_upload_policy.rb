# typed: strict

module Galleries
  class BulkUploadPolicy < ApplicationPolicy
    Record = type_member { {fixed: Galleries::BulkUpload} }

    sig { returns(T.nilable(T::Boolean)) }
    def new?
      user_owns_gallery?
    end

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
