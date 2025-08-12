require "rails_helper"

RSpec.describe RecipeGroupPolicy do
  permissions :index?, :new?, :create? do
    it "grants access when user is present" do
      user = build(:user)
      expect(described_class).to permit(user, RecipeGroup)
    end

    it "denies access when user is nil" do
      expect(described_class).not_to permit(nil, RecipeGroup)
    end
  end

  permissions :show? do
    it "grants access when user owns the record" do
      user = build(:user)
      recipe_group = build(:recipe_group, owner: user)

      expect(described_class).to permit(user, recipe_group)
    end

    it "grants access when user has shared access via user group" do
      owner = create(:user)
      user = create(:user)
      user_group = create(:user_group, owner: user)
      recipe_group = create(:recipe_group, owner: owner, user_groups: [user_group])

      expect(described_class).to permit(user, recipe_group)
    end

    it "denies access when user does not own the record and has no shared access" do
      user = build(:user)
      other_user = build(:user)
      other_users_recipe_group = build(:recipe_group, owner: other_user)

      expect(described_class).not_to permit(user, other_users_recipe_group)
    end

    it "denies access when user is nil" do
      recipe_group = build(:recipe_group)
      expect(described_class).not_to permit(nil, recipe_group)
    end
  end

  permissions :edit?, :update?, :destroy? do
    it "grants access when user owns the record" do
      user = build(:user)
      recipe_group = build(:recipe_group, owner: user)

      expect(described_class).to permit(user, recipe_group)
    end

    it "denies access when user has shared access but does not own the record" do
      owner = create(:user)
      user = create(:user)
      user_group = create(:user_group, owner: user)
      recipe_group = create(:recipe_group, owner: owner, user_groups: [user_group])

      expect(described_class).not_to permit(user, recipe_group)
    end

    it "denies access when user does not own the record" do
      user = build(:user)
      other_user = build(:user)
      other_users_recipe_group = build(:recipe_group, owner: other_user)

      expect(described_class).not_to permit(user, other_users_recipe_group)
    end

    it "denies access when user is nil" do
      recipe_group = build(:recipe_group)
      expect(described_class).not_to permit(nil, recipe_group)
    end
  end

  describe described_class::Scope do
    it "returns owned and shared recipe groups for the user" do
      user = create(:user)
      other_user = create(:user)

      # Recipe groups owned by user
      owned_group1 = create(:recipe_group, owner: user)
      owned_group2 = create(:recipe_group, owner: user)

      # Recipe group shared with user via user group
      user_group = create(:user_group, owner: user)
      shared_group = create(:recipe_group, owner: other_user, user_groups: [user_group])

      # Recipe group not accessible to user
      create(:recipe_group, owner: other_user)

      scope = described_class.new(user, RecipeGroup.all).resolve

      expect(scope).to contain_exactly(owned_group1, owned_group2, shared_group)
    end

    it "returns empty collection when user is nil" do
      create(:recipe_group)

      scope = described_class.new(nil, RecipeGroup.all).resolve

      expect(scope).to be_empty
    end
  end
end
