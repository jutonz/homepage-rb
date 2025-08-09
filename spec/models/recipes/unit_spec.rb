# == Schema Information
#
# Table name: recipes_units
#
#  id           :bigint           not null, primary key
#  abbreviation :string           not null
#  name         :string           not null
#  unit_type    :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_recipes_units_on_abbreviation  (abbreviation) UNIQUE
#  index_recipes_units_on_name          (name) UNIQUE
#  index_recipes_units_on_unit_type     (unit_type)
#
require "rails_helper"

RSpec.describe Recipes::Unit, type: :model do
  subject { create(:recipes_unit) }

  it { is_expected.to have_many(:recipe_ingredients) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name) }
  it { is_expected.to validate_presence_of(:abbreviation) }
  it { is_expected.to validate_uniqueness_of(:abbreviation) }
  it { is_expected.to validate_presence_of(:unit_type) }
  it { is_expected.to validate_inclusion_of(:unit_type).in_array(%w[volume weight count]) }

  it "has a valid factory" do
    expect(subject).to be_valid
  end
end
