# frozen_string_literal: true

require "rails_helper"

RSpec.describe Plants::PlantImageUpload do
  describe "#save" do
    it "creates multiple images" do
      user = create(:user)
      plant = create(:plant, user:)
      files = [
        fixture_file_upload("audiosurf.jpg", "image/jpeg"),
        fixture_file_upload("audiosurf.jpg", "image/jpeg")
      ]

      service = described_class.new(
        plant:,
        files:,
        taken_at: "2024-01-02"
      )

      result = nil

      expect do
        result = service.save
      end.to(change { Plants::PlantImage.count }.by(2))

      expect(result.saved?).to(eq(true))
    end

    it "returns errors when no files are provided" do
      user = create(:user)
      plant = create(:plant, user:)

      service = described_class.new(
        plant:,
        files: nil,
        taken_at: "2024-01-02"
      )

      result = service.save

      expect(result.saved?).to(eq(false))
      expect(result.plant_image.errors[:file]).not_to(be_empty)
    end
  end
end
