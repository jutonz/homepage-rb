module Galleries
  class ImagePolicy < ApplicationPolicy
    def index?
      user_owns_gallery?
    end

    def show?
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
      user && record.gallery.user == user
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none unless user

        scope.joins(:gallery).where(gallery: {user:})
      end
    end
  end
end
