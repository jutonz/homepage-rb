module Galleries
  class ImagePolicy < ApplicationPolicy
    def index?
      user.present? && user_owns_gallery?
    end

    def show?
      user.present? && user_owns_gallery?
    end

    def create?
      user.present? && user_owns_gallery?
    end

    def update?
      user.present? && user_owns_gallery?
    end

    def destroy?
      user.present? && user_owns_gallery?
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none unless user

        scope.joins(:gallery).where(gallery: {user:})
      end
    end

    private

    def user_owns_gallery?
      return false unless record.respond_to?(:gallery)
      return false unless record.gallery

      record.gallery.user == user
    end
  end
end
