# typed: strict

module Galleries
  class RemoteVideoDownloadPolicy < ApplicationPolicy
    Record = type_member { {fixed: Galleries::RemoteVideoDownload} }

    sig { returns(T.nilable(T::Boolean)) }
    def index?
      user_owns_gallery?
    end

    sig { returns(T.nilable(T::Boolean)) }
    def new?
      user_owns_gallery?
    end

    sig { returns(T.nilable(T::Boolean)) }
    def create?
      user_owns_gallery?
    end

    sig { returns(T.nilable(T::Boolean)) }
    def update?
      user_owns_gallery?
    end

    sig { returns(T.nilable(T::Boolean)) }
    def destroy?
      user_owns_gallery?
    end

    private

    sig { returns(T.nilable(T::Boolean)) }
    def user_owns_gallery?
      gallery = record.gallery
      return false unless gallery

      user && gallery.user == user
    end
  end
end
