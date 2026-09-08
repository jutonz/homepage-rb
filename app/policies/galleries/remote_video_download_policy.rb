# typed: true

module Galleries
  class RemoteVideoDownloadPolicy < ApplicationPolicy
    Record = type_member { {fixed: Galleries::RemoteVideoDownload} }

    def index?
      user_owns_gallery?
    end

    def new?
      user_owns_gallery?
    end

    def create?
      user_owns_gallery?
    end

    def update?
      user_owns_gallery?
    end

    def destroy?
      user_owns_gallery?
    end

    private

    def user_owns_gallery?
      gallery = record.gallery
      return false unless gallery

      user && gallery.user == user
    end
  end
end
