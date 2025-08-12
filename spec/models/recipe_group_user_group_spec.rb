require "rails_helper"

RSpec.describe RecipeGroupUserGroup do
  subject { create(:recipe_group_user_group) }

  it { is_expected.to belong_to(:recipe_group) }
  it { is_expected.to belong_to(:user_group) }
  it { is_expected.to validate_presence_of(:recipe_group_id) }
  it { is_expected.to validate_presence_of(:user_group_id) }
  it {
    is_expected.to validate_uniqueness_of(:recipe_group_id).scoped_to(:user_group_id)
  }

  it "has a valid factory" do
    expect(subject).to be_valid
  end

  def setup_duplicate_association_test
    recipe_group = create(:recipe_group)
    user_group = create(:user_group)
    create(:recipe_group_user_group, recipe_group:, user_group:)
    [recipe_group, user_group]
  end

  it "prevents duplicate associations for same recipe group and user group" do
    recipe_group, user_group = setup_duplicate_association_test

    expect {
      create(:recipe_group_user_group, recipe_group:, user_group:)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
