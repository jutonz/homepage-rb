require "rails_helper"

RSpec.describe Galleries::BulkUpload do
  describe "#save" do
    it "saves an image from a signed blob id" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(
        gallery:,
        signed_id: blob.signed_id
      )

      expect(bulk_upload.save).to be(true)
      expect(gallery.images.count).to eql(1)
    end

    it "returns the created image via #image" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(
        gallery:,
        signed_id: blob.signed_id
      )

      bulk_upload.save

      expect(bulk_upload.image).to be_a(Galleries::Image)
      expect(bulk_upload.image).to be_persisted
    end

    it "marks the image as processing" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(
        gallery:,
        signed_id: blob.signed_id
      )

      bulk_upload.save

      expect(bulk_upload.image.processing).to be(true)
    end

    it "is false if signed_id is blank" do
      gallery = build_stubbed(:gallery)
      bulk_upload = described_class.new(gallery:, signed_id: nil)

      expect(bulk_upload.save).to be(false)
      expect(bulk_upload.errors[:signed_id]).to include(
        "can't be blank"
      )
    end

    it "adds a 'tagging needed' tag" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(
        gallery:,
        signed_id: blob.signed_id
      )

      bulk_upload.save

      expect(
        bulk_upload.image.tags.pluck(:name)
      ).to include("tagging needed")
    end

    it "applies selected tags to the image" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:)
      bulk_upload = described_class.new(
        gallery:,
        signed_id: blob.signed_id,
        tag_ids: [tag.id.to_s]
      )

      bulk_upload.save

      expect(bulk_upload.image.tags).to include(tag)
    end

    it "ignores tags from a different gallery" do
      gallery = create(:gallery)
      other_gallery = create(:gallery)
      other_tag = create(
        :galleries_tag, gallery: other_gallery
      )
      bulk_upload = described_class.new(
        gallery:,
        signed_id: blob.signed_id,
        tag_ids: [other_tag.id.to_s]
      )

      bulk_upload.save

      expect(
        bulk_upload.image.tags.pluck(:name)
      ).to eql(["tagging needed"])
    end

    it "works when tag_ids is nil" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(
        gallery:,
        signed_id: blob.signed_id,
        tag_ids: nil
      )

      result = bulk_upload.save

      expect(result).to be(true)
      expect(gallery.images.count).to eql(1)
    end

    it "enqueues ImageVariantJob for the image" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(
        gallery:,
        signed_id: blob.signed_id
      )

      bulk_upload.save

      expect(
        Galleries::ImageVariantJob
      ).to have_been_enqueued.with(bulk_upload.image)
    end

    it "enqueues ImagePerceptualHashJob for the image" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(
        gallery:,
        signed_id: blob.signed_id
      )

      bulk_upload.save

      expect(
        Galleries::ImagePerceptualHashJob
      ).to have_been_enqueued.with(bulk_upload.image)
    end
  end

  private

  def blob
    @blob ||= ActiveStorage::Blob.create_and_upload!(
      io: fixture_file_upload("audiosurf.jpg", "image/jpeg"),
      filename: "audiosurf.jpg",
      content_type: "image/jpeg"
    )
  end
end
