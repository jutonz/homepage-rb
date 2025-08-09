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

  describe "scopes" do
    let!(:volume_unit) { create(:recipes_unit, unit_type: "volume") }
    let!(:weight_unit) { create(:recipes_unit, unit_type: "weight") }
    let!(:count_unit) { create(:recipes_unit, unit_type: "count") }

    it "filters by volume" do
      expect(Recipes::Unit.volume).to contain_exactly(volume_unit)
    end

    it "filters by weight" do
      expect(Recipes::Unit.weight).to contain_exactly(weight_unit)
    end

    it "filters by count" do
      expect(Recipes::Unit.by_count).to contain_exactly(count_unit)
    end
  end

  describe "#to_s" do
    it "returns the name" do
      unit = build(:recipes_unit, name: "cup")
      expect(unit.to_s).to eq("cup")
    end
  end

  it "has a valid factory" do
    expect(subject).to be_valid
  end
end
