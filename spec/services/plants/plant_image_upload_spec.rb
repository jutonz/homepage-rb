# frozen_string_literal: true

require "rails_helper"

RSpec.describe Plants::PlantImageUpload do
  describe "#save" do
    it "creates multiple images and returns a plural notice" do
      user = create(:user)
      plant = create(:plant, user:)
      calls = []
      files = [
        fixture_file_upload("audiosurf.jpg", "image/jpeg"),
        fixture_file_upload("audiosurf.jpg", "image/jpeg")
      ]

      service = described_class.new(
        plant:,
        files:,
        taken_at: "2024-01-02",
        authorizer: ->(record) { calls << record }
      )

      result = nil

      expect do
        result = service.save
      end.to(change { Plants::PlantImage.count }.by(2))

      expect(result.saved?).to(eq(true))
      expect(result.notice).to(eq("Images were added."))
      expect(calls.length).to(eq(2))
    end

    it "returns errors when no files are provided" do
      user = create(:user)
      plant = create(:plant, user:)
      calls = []

      service = described_class.new(
        plant:,
        files: nil,
        taken_at: "2024-01-02",
        authorizer: ->(record) { calls << record }
      )

      result = service.save

      expect(result.saved?).to(eq(false))
      expect(result.plant_image.errors[:file]).not_to(be_empty)
      expect(calls.length).to(eq(1))
    end
  end
end
