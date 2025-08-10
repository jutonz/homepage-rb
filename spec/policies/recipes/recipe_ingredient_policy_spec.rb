require "rails_helper"

RSpec.describe Recipes::RecipeIngredientPolicy do
  permissions :index?, :show?, :create?, :new?, :edit?, :update?, :destroy? do
    it "grants access when user owns the recipe" do
      user = build(:user)
      recipe = build(:recipes_recipe, user:)
      ingredient = build(:recipes_ingredient, user:)
      recipe_ingredient = build(:recipes_recipe_ingredient, recipe:, ingredient:)

      expect(described_class).to permit(user, recipe_ingredient)
    end

    it "denies access when user does not own the recipe" do
      user = build(:user)
      other_user = build(:user)
      recipe = build(:recipes_recipe, user: other_user)
      ingredient = build(:recipes_ingredient, user: other_user)
      recipe_ingredient = build(:recipes_recipe_ingredient, recipe:, ingredient:)

      expect(described_class).not_to permit(user, recipe_ingredient)
    end

    it "denies access when user is nil" do
      user = build(:user)
      recipe = build(:recipes_recipe, user:)
      ingredient = build(:recipes_ingredient, user:)
      recipe_ingredient = build(:recipes_recipe_ingredient, recipe:, ingredient:)

      expect(described_class).not_to permit(nil, recipe_ingredient)
    end
  end

  describe described_class::Scope do
    it "returns only recipe ingredients for recipes owned by the user" do
      user = create(:user)
      other_user = create(:user)

      user_recipe = create(:recipes_recipe, user:)
      user_ingredient = create(:recipes_ingredient, user:)
      user_recipe_ingredient = create(:recipes_recipe_ingredient, recipe: user_recipe, ingredient: user_ingredient)

      other_recipe = create(:recipes_recipe, user: other_user)
      other_ingredient = create(:recipes_ingredient, user: other_user)
      create(:recipes_recipe_ingredient, recipe: other_recipe, ingredient: other_ingredient)

      scope = described_class.new(user, Recipes::RecipeIngredient.all).resolve

      expect(scope).to contain_exactly(user_recipe_ingredient)
    end

    it "returns empty collection when user is nil" do
      user = create(:user)
      recipe = create(:recipes_recipe, user:)
      ingredient = create(:recipes_ingredient, user:)
      create(:recipes_recipe_ingredient, recipe:, ingredient:)

      scope = described_class.new(nil, Recipes::RecipeIngredient.all).resolve

      expect(scope).to be_empty
    end
  end
end
