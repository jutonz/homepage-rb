require "rails_helper"

RSpec.describe Galleries::BulkDelete do
  it { is_expected.to validate_presence_of(:gallery) }
  it { is_expected.to validate_presence_of(:image_ids) }

  describe "#save" do
    it "destroys selected images" do
      gallery = create(:gallery)
      image1 = create(:galleries_image, gallery:)
      image2 = create(:galleries_image, gallery:)
      bulk_delete = described_class.new(
        gallery:,
        image_ids: [image1.id, image2.id]
      )

      bulk_delete.save

      expect(Galleries::Image.where(
        id: [image1.id, image2.id]
      )).to be_empty
    end

    it "only destroys images belonging to the gallery" do
      gallery = create(:gallery)
      other_gallery = create(:gallery)
      image = create(:galleries_image, gallery:)
      other_image = create(
        :galleries_image,
        gallery: other_gallery
      )
      bulk_delete = described_class.new(
        gallery:,
        image_ids: [image.id, other_image.id]
      )

      bulk_delete.save

      expect(
        Galleries::Image.where(id: other_image.id)
      ).to exist
    end

    it "returns false when invalid" do
      bulk_delete = described_class.new(
        gallery: nil,
        image_ids: []
      )

      expect(bulk_delete.save).to be false
    end
  end
end
