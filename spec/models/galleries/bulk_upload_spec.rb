require "rails_helper"

RSpec.describe Galleries::BulkUpload do
  describe "#save" do
    it "saves multiple images" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(
        gallery:,
        files: [
          fixture_file_upload("audiosurf.jpg", "image/jpeg"),
          fixture_file_upload("audiosurf.jpg", "image/jpeg")
        ]
      )

      expect(bulk_upload.save).to be(true)
      expect(gallery.images.count).to eql(2)
    end

    it "ignores blank files" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(
        gallery:,
        files: [
          "",
          fixture_file_upload("audiosurf.jpg", "image/jpeg")
        ]
      )

      expect(bulk_upload.save).to be(true)
      expect(gallery.images.count).to eql(1)
    end

    it "is false if there are no files" do
      gallery = build_stubbed(:gallery)
      bulk_upload = described_class.new(gallery:, files: [])

      expect(bulk_upload.save).to be(false)
      expect(bulk_upload.errors[:files]).to include("can't be blank")
    end
  end
end
