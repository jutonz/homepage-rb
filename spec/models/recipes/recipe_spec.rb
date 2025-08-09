# == Schema Information
#
# Table name: recipes_recipes
#
#  id           :bigint           not null, primary key
#  description  :text
#  instructions :text
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_recipes_recipes_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Recipes::Recipe, type: :model do
  subject { build(:recipes_recipe) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:recipe_ingredients).dependent(:destroy) }
  it { is_expected.to have_many(:ingredients).through(:recipe_ingredients) }

  it { is_expected.to validate_presence_of(:name) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end
end
