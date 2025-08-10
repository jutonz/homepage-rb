module Recipes
  class RecipeIngredientPolicy < ApplicationPolicy
    def index?
      user.present? && user_owns_recipe?
    end

    def show?
      user.present? && user_owns_recipe?
    end

    def create?
      user.present? && user_owns_recipe?
    end

    def update?
      user.present? && user_owns_recipe?
    end

    def destroy?
      user.present? && user_owns_recipe?
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        return scope.none unless user

        scope.joins(:recipe).where(recipe: {user:})
      end
    end

    private

    def user_owns_recipe?
      return false unless record.respond_to?(:recipe)
      return false unless record.recipe

      record.recipe.user == user
    end
  end
end
