module Recipes
  class RecipeIngredientPolicy < ApplicationPolicy
    def index?
      user_owns_recipe?
    end

    def show?
      user_owns_recipe?
    end

    def create?
      user_owns_recipe?
    end

    def update?
      user_owns_recipe?
    end

    def destroy?
      user_owns_recipe?
    end

    private

    def user_owns_recipe?
      user.present? && record.recipe.user == user
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none unless user
        scope.joins(:recipe).where(recipe: {user:})
      end
    end
  end
end
