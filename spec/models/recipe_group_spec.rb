# == Schema Information
#
# Table name: recipe_groups
# Database name: primary
#
#  id            :bigint           not null, primary key
#  description   :text
#  name          :string           not null
#  recipes_count :integer          default(0), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  owner_id      :bigint           not null
#
# Indexes
#
#  index_recipe_groups_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
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
