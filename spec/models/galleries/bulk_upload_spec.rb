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

    it "generates image variants" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(gallery:, files: [audiosurf_jpg])

      result = bulk_upload.save

      expect(result).to be(true)
      image = gallery.images.first
      expect(image.file.variant(:thumb).blob).to be_present
    end

    it "generates perceptual hashes" do
      gallery = create(:gallery)
      bulk_upload = described_class.new(gallery:, files: [audiosurf_jpg])
      expect(ActiveJob).to receive(:perform_all_later) do |jobs|
        expect(jobs.size).to eql(1)
        expect(jobs.first.class).to eql(Galleries::ImagePerceptualHashJob)
      end

      result = bulk_upload.save

      expect(result).to be(true)
    end
  end

  private

  def audiosurf_jpg = fixture_file_upload("audiosurf.jpg", "image/jpeg")
end
