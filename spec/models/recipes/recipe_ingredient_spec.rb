# == Schema Information
#
# Table name: recipes_recipe_ingredients
#
#  id            :bigint           not null, primary key
#  notes         :text
#  quantity      :decimal(8, 2)
#  unit          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ingredient_id :bigint           not null
#  recipe_id     :bigint           not null
#  unit_id       :bigint
#
# Indexes
#
#  idx_on_recipe_id_ingredient_id_b1a1ea5019          (recipe_id,ingredient_id) UNIQUE
#  index_recipes_recipe_ingredients_on_ingredient_id  (ingredient_id)
#  index_recipes_recipe_ingredients_on_recipe_id      (recipe_id)
#  index_recipes_recipe_ingredients_on_unit_id        (unit_id)
#
# Foreign Keys
#
#  fk_rails_...  (ingredient_id => recipes_ingredients.id)
#  fk_rails_...  (recipe_id => recipes_recipes.id)
#  fk_rails_...  (unit_id => recipes_units.id)
#
require "rails_helper"

RSpec.describe Recipes::RecipeIngredient, type: :model do
  subject { create(:recipes_recipe_ingredient) }

  it { is_expected.to belong_to(:recipe) }
  it { is_expected.to belong_to(:ingredient) }
  it { is_expected.to belong_to(:unit).optional }

  it { is_expected.to validate_presence_of(:recipe_id) }
  it { is_expected.to validate_presence_of(:ingredient_id) }
  it { is_expected.to validate_presence_of(:quantity) }
  it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }
  it { is_expected.to validate_uniqueness_of(:recipe_id).scoped_to(:ingredient_id) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end
end
