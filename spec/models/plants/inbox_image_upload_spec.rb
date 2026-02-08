# frozen_string_literal: true

require "rails_helper"

RSpec.describe Plants::InboxImageUpload do
  describe "#save" do
    it "creates multiple images" do
      user = create(:user)
      files = [
        fixture_file_upload("audiosurf.jpg", "image/jpeg"),
        fixture_file_upload("audiosurf.jpg", "image/jpeg")
      ]

      service = described_class.new(
        user:,
        files:,
        taken_at: "2024-01-02"
      )

      result = nil

      expect do
        result = service.save
      end.to(change { Plants::InboxImage.count }.by(2))

      expect(result.saved?).to(eq(true))
    end

    it "returns errors when no files are provided" do
      user = create(:user)

      service = described_class.new(
        user:,
        files: nil,
        taken_at: "2024-01-02"
      )

      result = service.save

      expect(result.saved?).to(eq(false))
      expect(result.inbox_image.errors[:file]).not_to(be_empty)
    end
  end
end
