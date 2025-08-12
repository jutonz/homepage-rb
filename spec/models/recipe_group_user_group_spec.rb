require "rails_helper"

RSpec.describe RecipeGroupUserGroup do
  subject { create(:recipe_group_user_group) }

  it { is_expected.to belong_to(:recipe_group) }
  it { is_expected.to belong_to(:user_group) }
  it {
    is_expected.to validate_uniqueness_of(:recipe_group_id).scoped_to(:user_group_id)
  }

  it "has a valid factory" do
    expect(subject).to be_valid
  end
end
