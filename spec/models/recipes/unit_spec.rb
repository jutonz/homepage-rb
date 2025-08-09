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
