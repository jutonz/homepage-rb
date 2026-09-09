# typed: true

module Recipes
  class RecipeIngredientPolicy < UserOwnedPolicy
    Record = type_member { {fixed: Recipes::RecipeIngredient} }

    # A recipe ingredient has no `user` column, so it cannot use the
    # owner-filtered query that `UserOwnedPolicy` supplies.
    sig { params(user: T.nilable(User)).returns(ActiveRecord::Relation) }
    def self.scope_for(user)
      return model.none if user.blank?
      model.joins(:recipe).where(recipe: {user:})
    end

    def index?
      user_owns_record?
    end

    def new?
      user_owns_record?
    end

    def create?
      user_owns_record?
    end

    private

    def user_owns_record?
      user && record.recipe&.user == user
    end
  end
end
