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

  describe ".scope_for" do
    it "returns owned and shared recipe groups for the user" do
      user, other_user = create_pair(:user)
      owned_group1, owned_group2 = create_pair(:recipe_group, owner: user)
      user_group = create(:user_group, owner: user)
      shared_group = create(
        :recipe_group,
        owner: other_user,
        user_groups: [user_group]
      )
      _inaccessible_group = create(:recipe_group, owner: other_user)

      policy_scope = described_class.scope_for(user)

      expect(policy_scope)
        .to contain_exactly(owned_group1, owned_group2, shared_group)
    end

    it "returns an empty collection when user is nil" do
      create(:recipe_group)

      policy_scope = described_class.scope_for(nil)

      expect(policy_scope).to be_empty
    end
  end
end
