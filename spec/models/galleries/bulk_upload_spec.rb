require "rails_helper"

RSpec.describe Galleries::BulkUpload do
  describe "#save" do
    it "saves multiple images" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(
        gallery:,
        files: [audiosurf_jpg, audiosurf_jpg]
      )

      expect(bulk_upload.save).to be(true)
      expect(gallery.images.count).to eql(2)
    end

    it "ignores blank files" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(
        gallery:,
        files: ["", audiosurf_jpg]
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

    it "creates and applies a 'tagging needed' tag if it doesn't exist" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(gallery:, files: [audiosurf_jpg])

      result = bulk_upload.save

      expect(result).to be(true)
      tag = gallery.tags.first
      expect(tag).to have_attributes(
        name: "tagging needed",
        user: gallery.user
      )
      expect(gallery.images.first.tags.pluck(:id)).to eql([tag.id])
    end

    it "if a 'tagging needed' tag already exists, applies it" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:, name: "tagging needed")
      bulk_upload = described_class.new(gallery:, files: [audiosurf_jpg])

      result = bulk_upload.save

      expect(result).to be(true)
      expect(gallery.images.first.tags.pluck(:id)).to eql([tag.id])
    end
  end

  private

  def audiosurf_jpg = fixture_file_upload("audiosurf.jpg", "image/jpeg")
end
