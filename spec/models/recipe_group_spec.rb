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
end
