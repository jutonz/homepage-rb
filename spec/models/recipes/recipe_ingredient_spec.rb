# == Schema Information
#
# Table name: recipes_recipe_ingredients
# Database name: primary
#
#  id            :bigint           not null, primary key
#  denominator   :integer
#  notes         :text
#  numerator     :integer
#  quantity      :decimal(8, 2)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  ingredient_id :bigint           not null
#  recipe_id     :bigint           not null
#  unit_id       :bigint           not null
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
  subject { build(:recipes_recipe_ingredient) }

  it { is_expected.to belong_to(:recipe) }
  it { is_expected.to belong_to(:ingredient) }
  it { is_expected.to belong_to(:unit) }

  it { is_expected.to validate_presence_of(:recipe_id) }
  it { is_expected.to validate_presence_of(:ingredient_id) }
  it { is_expected.to validate_presence_of(:quantity) }
  it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }
  it { is_expected.to validate_uniqueness_of(:recipe_id).scoped_to(:ingredient_id) }

  it "has a valid factory" do
    expect(build_stubbed(:recipes_recipe_ingredient)).to be_valid
  end

  describe "fraction functionality" do
    describe "#quantity_string=" do
      it "parses and stores simple fractions" do
        recipe_ingredient = build(:recipes_recipe_ingredient)
        recipe_ingredient.quantity_string = "1/2"
        expect(recipe_ingredient.numerator).to eq(1)
        expect(recipe_ingredient.denominator).to eq(2)
        expect(recipe_ingredient.quantity).to eq(0.5)
      end

      it "parses and stores mixed numbers" do
        recipe_ingredient = build(:recipes_recipe_ingredient)
        recipe_ingredient.quantity_string = "2 1/3"
        expect(recipe_ingredient.numerator).to eq(7)
        expect(recipe_ingredient.denominator).to eq(3)
        expect(recipe_ingredient.quantity.to_f).to be_within(0.01).of(2.33)
      end

      it "parses and stores whole numbers" do
        recipe_ingredient = build(:recipes_recipe_ingredient)
        recipe_ingredient.quantity_string = "3"
        expect(recipe_ingredient.numerator).to eq(3)
        expect(recipe_ingredient.denominator).to eq(1)
        expect(recipe_ingredient.quantity).to eq(3.0)
      end

      it "parses and stores decimals" do
        recipe_ingredient = build(:recipes_recipe_ingredient)
        recipe_ingredient.quantity_string = "0.25"
        expect(recipe_ingredient.numerator).to eq(1)
        expect(recipe_ingredient.denominator).to eq(4)
        expect(recipe_ingredient.quantity).to eq(0.25)
      end

      it "clears fraction fields for invalid input" do
        recipe_ingredient = build(:recipes_recipe_ingredient)
        recipe_ingredient.quantity_string = "invalid"
        expect(recipe_ingredient.numerator).to be_nil
        expect(recipe_ingredient.denominator).to be_nil
      end

      it "tries decimal parsing for invalid fractions" do
        recipe_ingredient = build(:recipes_recipe_ingredient)
        recipe_ingredient.quantity_string = "2.5"
        expect(recipe_ingredient.quantity).to eq(2.5)
      end
    end

    describe "#quantity_string" do
      it "returns formatted fraction for stored fractions" do
        recipe_ingredient = build(:recipes_recipe_ingredient)
        recipe_ingredient.numerator = 3
        recipe_ingredient.denominator = 4
        expect(recipe_ingredient.quantity_string).to eq("3/4")
      end

      it "returns formatted mixed number for improper fractions" do
        recipe_ingredient = build(:recipes_recipe_ingredient)
        recipe_ingredient.numerator = 5
        recipe_ingredient.denominator = 2
        expect(recipe_ingredient.quantity_string).to eq("2 1/2")
      end

      it "returns decimal value when no fraction is stored" do
        recipe_ingredient = build(:recipes_recipe_ingredient)
        recipe_ingredient.numerator = nil
        recipe_ingredient.denominator = nil
        recipe_ingredient.quantity = 1.5
        expect(recipe_ingredient.quantity_string).to eq("1.5")
      end

      it "returns empty string for no value" do
        recipe_ingredient = build(:recipes_recipe_ingredient)
        recipe_ingredient.numerator = nil
        recipe_ingredient.denominator = nil
        recipe_ingredient.quantity = nil
        expect(recipe_ingredient.quantity_string).to eq("")
      end
    end

    describe "#formatted_quantity" do
      it "formats fractions without unicode by default" do
        recipe_ingredient = build(:recipes_recipe_ingredient)
        recipe_ingredient.numerator = 1
        recipe_ingredient.denominator = 2
        expect(recipe_ingredient.formatted_quantity).to eq("1/2")
      end

      it "formats fractions with unicode when requested" do
        recipe_ingredient = build(:recipes_recipe_ingredient)
        recipe_ingredient.numerator = 1
        recipe_ingredient.denominator = 2
        expect(recipe_ingredient.formatted_quantity(use_unicode: true)).to eq("½")
      end
    end

    describe "fraction validation" do
      it "validates numerator presence when denominator is present" do
        valid_ingredient = build(:recipes_recipe_ingredient)
        valid_ingredient.numerator = nil
        valid_ingredient.denominator = 2
        expect(valid_ingredient).not_to be_valid
        expect(valid_ingredient.errors[:numerator]).to include("must be present when denominator is set")
      end

      it "validates denominator presence when numerator is present" do
        valid_ingredient = build(:recipes_recipe_ingredient)
        valid_ingredient.numerator = 1
        valid_ingredient.denominator = nil
        expect(valid_ingredient).not_to be_valid
        expect(valid_ingredient.errors[:denominator]).to include("must be present when numerator is set")
      end

      it "validates denominator is not zero" do
        valid_ingredient = build(:recipes_recipe_ingredient)
        valid_ingredient.numerator = 1
        valid_ingredient.denominator = 0
        expect(valid_ingredient).not_to be_valid
        expect(valid_ingredient.errors[:denominator]).to include("cannot be zero")
      end

      it "validates numerator is greater than zero" do
        valid_ingredient = build(:recipes_recipe_ingredient)
        valid_ingredient.numerator = 0
        valid_ingredient.denominator = 2
        expect(valid_ingredient).not_to be_valid
        expect(valid_ingredient.errors[:numerator]).to include("must be greater than zero")
      end

      it "allows valid fractions" do
        valid_ingredient = build_stubbed(:recipes_recipe_ingredient)
        valid_ingredient.numerator = 3
        valid_ingredient.denominator = 4
        expect(valid_ingredient).to be_valid
      end

      it "allows no fraction fields to be set" do
        valid_ingredient = build_stubbed(:recipes_recipe_ingredient)
        valid_ingredient.numerator = nil
        valid_ingredient.denominator = nil
        expect(valid_ingredient).to be_valid
      end
    end
  end
end
