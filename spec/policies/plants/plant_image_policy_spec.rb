require "rails_helper"

RSpec.describe Plants::PlantImagePolicy do
  permissions :new?, :create?, :destroy? do
    it "grants access when user owns the plant" do
      user = build(:user)
      plant = build(:plant, user:)
      plant_image = build(:plants_plant_image, plant:)

      expect(described_class).to(permit(user, plant_image))
    end

    it "denies access when user does not own the plant" do
      user, other_user = build_pair(:user)
      plant = build(:plant, user: other_user)
      plant_image = build(:plants_plant_image, plant:)

      expect(described_class).not_to(permit(user, plant_image))
    end

    it "denies access when user is nil" do
      plant = build(:plant)
      plant_image = build(:plants_plant_image, plant:)

      expect(described_class).not_to(permit(nil, plant_image))
    end
  end

  describe described_class::Scope do
    it "returns plant_images for plants belonging to the user" do
      user, other_user = create_pair(:user)
      plant1 = create(:plant, user:)
      plant2 = create(:plant, user:)
      other_plant = create(:plant, user: other_user)
      plant_image1 = create(:plants_plant_image, plant: plant1)
      plant_image2 = create(:plants_plant_image, plant: plant2)
      _other_image = create(:plants_plant_image, plant: other_plant)

      scope = described_class.new(user, Plants::PlantImage.all).resolve

      expect(scope).to(contain_exactly(plant_image1, plant_image2))
    end

    it "returns empty collection when user is nil" do
      user = create(:user)
      plant = create(:plant, user:)
      create(:plants_plant_image, plant:)

      scope = described_class.new(nil, Plants::PlantImage.all).resolve

      expect(scope).to(be_empty)
    end
  end
end
