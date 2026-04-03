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

    it "adds a 'tagging needed' tag" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(gallery:, files: [audiosurf_jpg])

      result = bulk_upload.save

      expect(result).to be(true)
      image = gallery.images.first
      expect(image.tags.pluck(:name)).to eql(["tagging needed"])
    end

    it "enqueues image processing jobs" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(
        gallery:, files: [audiosurf_jpg]
      )

      result = bulk_upload.save

      expect(result).to be(true)
      image = gallery.images.first
      expect(Galleries::ImageProcessingJob)
        .to have_been_enqueued.with(image)
    end

    it "applies selected tags to all uploaded images" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      bulk_upload = described_class.new(
        gallery:,
        files: [audiosurf_jpg, audiosurf_jpg],
        tag_ids: [tag.id.to_s]
      )

      result = bulk_upload.save

      expect(result).to be(true)
      gallery.images.each do |image|
        expect(image.tags).to include(tag)
      end
    end

    it "ignores tags from a different gallery" do
      gallery = create(:gallery)
      other_gallery = create(:gallery)
      other_tag = create(
        :galleries_tag, gallery: other_gallery
      )
      bulk_upload = described_class.new(
        gallery:,
        files: [audiosurf_jpg],
        tag_ids: [other_tag.id.to_s]
      )

      result = bulk_upload.save

      expect(result).to be(true)
      image = gallery.images.first
      expect(image.tags.pluck(:name)).to eql(
        ["tagging needed"]
      )
    end

    it "works when tag_ids is nil" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(
        gallery:,
        files: [audiosurf_jpg],
        tag_ids: nil
      )

      result = bulk_upload.save

      expect(result).to be(true)
      expect(gallery.images.count).to eql(1)
    end

    it "enqueues processing for each image" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(
        gallery:,
        files: [audiosurf_jpg, audiosurf_jpg]
      )

      result = bulk_upload.save

      expect(result).to be(true)
      gallery.images.each do |image|
        expect(Galleries::ImageProcessingJob)
          .to have_been_enqueued.with(image)
      end
    end
  end

  private

  def audiosurf_jpg = fixture_file_upload("audiosurf.jpg", "image/jpeg")
end
