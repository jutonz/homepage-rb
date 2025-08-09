# == Schema Information
#
# Table name: recipes_ingredients
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_recipes_ingredients_on_user_id           (user_id)
#  index_recipes_ingredients_on_user_id_and_name  (user_id,name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Recipes::Ingredient, type: :model do
  subject { build(:recipes_ingredient) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:recipe_ingredients).dependent(:destroy) }
  it { is_expected.to have_many(:recipes).through(:recipe_ingredients) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:user_id) }

  it "has a valid factory" do
    ingredient = build(:recipes_ingredient)
    expect(ingredient).to be_valid
  end
end
