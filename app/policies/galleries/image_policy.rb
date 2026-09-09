# typed: true

module Galleries
  class ImagePolicy < ApplicationPolicy
    Record = type_member { {fixed: Galleries::Image} }

    sig { params(user: T.nilable(User)).returns(ActiveRecord::Relation) }
    def self.scope_for(user)
      return model.none unless user

      model.joins(:gallery).where(gallery: {user:})
    end

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
      user && record.gallery&.user == user
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none unless user

        scope.joins(:gallery).where(gallery: {user:})
      end
    end
  end
end
