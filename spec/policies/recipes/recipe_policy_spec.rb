require "rails_helper"

RSpec.describe Recipes::RecipePolicy do
  permissions :index?, :create? do
    it "grants access when user is present" do
      user = build(:user)
      expect(described_class).to permit(user, Recipes::Recipe)
    end

    it "denies access when user is nil" do
      expect(described_class).not_to permit(nil, Recipes::Recipe)
    end
  end

  permissions :show?, :update?, :destroy? do
    it "grants access when user owns the recipe" do
      user = build(:user)
      recipe = build(:recipes_recipe, user:)

      expect(described_class).to permit(user, recipe)
    end

    it "denies access when user does not own the recipe" do
      user = build(:user)
      other_user = build(:user)
      other_users_recipe = build(:recipes_recipe, user: other_user)

      expect(described_class).not_to permit(user, other_users_recipe)
    end

    it "denies access when user is nil" do
      user = build(:user)
      recipe = build(:recipes_recipe, user:)

      expect(described_class).not_to permit(nil, recipe)
    end
  end

  permissions :new? do
    it "grants access when user is present" do
      user = build(:user)
      expect(described_class).to permit(user, Recipes::Recipe)
    end

    it "denies access when user is nil" do
      expect(described_class).not_to permit(nil, Recipes::Recipe)
    end
  end

  permissions :edit? do
    it "grants access when user owns the recipe" do
      user = build(:user)
      recipe = build(:recipes_recipe, user:)

      expect(described_class).to permit(user, recipe)
    end

    it "denies access when user does not own the recipe" do
      user = build(:user)
      other_user = build(:user)
      other_users_recipe = build(:recipes_recipe, user: other_user)

      expect(described_class).not_to permit(user, other_users_recipe)
    end

    it "denies access when user is nil" do
      user = build(:user)
      recipe = build(:recipes_recipe, user:)

      expect(described_class).not_to permit(nil, recipe)
    end
  end

  describe described_class::Scope do
    it "returns only recipes belonging to the user" do
      user = create(:user)
      other_user = create(:user)
      user_recipe1 = create(:recipes_recipe, user:)
      user_recipe2 = create(:recipes_recipe, user:)
      create(:recipes_recipe, user: other_user)

      scope = described_class.new(user, Recipes::Recipe.all).resolve

      expect(scope).to contain_exactly(user_recipe1, user_recipe2)
    end

    it "returns empty collection when user is nil" do
      user = create(:user)
      create(:recipes_recipe, user:)

      scope = Recipes::RecipePolicy::Scope.new(nil, Recipes::Recipe.all).resolve

      expect(scope).to be_empty
    end
  end
end
