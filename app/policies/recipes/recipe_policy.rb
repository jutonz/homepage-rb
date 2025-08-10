module Recipes
  class RecipePolicy < ApplicationPolicy
    def index?
      user.present?
    end

    def show?
      user_owns_record?
    end

    def create?
      user.present?
    end

    def update?
      user_owns_record?
    end

    def destroy?
      user_owns_record?
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none unless user

        scope.where(user:)
      end
    end
  end
end
