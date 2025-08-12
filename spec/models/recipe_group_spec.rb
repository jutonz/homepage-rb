require "rails_helper"

RSpec.describe RecipeGroup do
  subject { build(:recipe_group) }

  it { is_expected.to belong_to(:owner) }
  it { is_expected.to have_many(:recipes).dependent(:destroy) }
  it { is_expected.to have_many(:recipe_group_user_groups).dependent(:destroy) }
  it { is_expected.to have_many(:user_groups) }
  it { is_expected.to validate_presence_of(:name) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  def setup_recipe_group_with_recipes
    recipe_group = create(:recipe_group)
    recipe1 = create(:recipes_recipe, recipe_group:)
    recipe2 = create(:recipes_recipe, recipe_group:)
    [recipe_group, recipe1, recipe2]
  end

  it "has many recipes" do
    recipe_group, recipe1, recipe2 = setup_recipe_group_with_recipes

    expect(recipe_group.recipes).to contain_exactly(recipe1, recipe2)
  end

  def setup_recipe_group_with_user_groups
    recipe_group = create(:recipe_group)
    user_group1 = create(:user_group)
    user_group2 = create(:user_group)
    create(:recipe_group_user_group, recipe_group:, user_group: user_group1)
    create(:recipe_group_user_group, recipe_group:, user_group: user_group2)
    [recipe_group, user_group1, user_group2]
  end

  it "has many user groups through recipe_group_user_groups" do
    recipe_group, user_group1, user_group2 = setup_recipe_group_with_user_groups

    expect(recipe_group.user_groups).to contain_exactly(user_group1, user_group2)
  end

  def setup_recipe_deletion_test
    recipe_group = create(:recipe_group)
    recipe = create(:recipes_recipe, recipe_group:)
    [recipe_group, recipe]
  end

  it "destroys recipes when recipe group is destroyed" do
    recipe_group, recipe = setup_recipe_deletion_test

    recipe_group.destroy!

    expect { recipe.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
