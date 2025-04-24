# == Schema Information
#
# Table name: galleries_images
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  gallery_id :bigint           not null
#
# Indexes
#
#  index_galleries_images_on_gallery_id  (gallery_id)
#
# Foreign Keys
#
#  fk_rails_...  (gallery_id => galleries.id)
#
require "rails_helper"

RSpec.describe Galleries::Image do
  it { is_expected.to belong_to(:gallery) }
  it { is_expected.to validate_presence_of(:file) }
  it { is_expected.to have_many(:image_tags).dependent(:destroy) }
  it { is_expected.to have_many(:tags) }

  it "has a valid factory" do
    expect(create(:galleries_image)).to be_valid
  end

  describe ".by_tags" do
    it "includes only images with the given tag" do
      image1, image2 = create_pair(:galleries_image)
      tag1, tag2 = create_pair(:galleries_tag)
      image1.add_tag(tag1)
      image2.add_tag(tag2)

      result = described_class.by_tags(tag1).pluck(:id)

      expect(result).to eql([image1.id])
    end

    it "if given multiple tags, returns images which have all of the tags" do
      has_both_tags, has_one_tag = create_pair(:galleries_image)
      tag1, tag2 = create_pair(:galleries_tag)
      has_both_tags.add_tag(tag1)
      has_both_tags.add_tag(tag2)
      has_one_tag.add_tag(tag1)

      result = described_class.by_tags([tag1, tag2]).pluck(:id)

      expect(result).to eql([has_both_tags.id])
    end
  end

  describe "#add_tag" do
    it "adds a tag to the image" do
      image = create(:galleries_image)
      tag = create(:galleries_tag, gallery: image.gallery)

      image.add_tag(tag)

      expect(image.reload.tag_ids).to eql([tag.id])
    end

    it "can add multiple tags at once" do
      image = create(:galleries_image)
      tag1, tag2 = create_pair(:galleries_tag, gallery: image.gallery)

      image.add_tag(tag1, tag2)

      expect(image.reload.tag_ids).to contain_exactly(tag1.id, tag2.id)
    end
  end

  describe "#remove_tag" do
    it "removes a tag from the image" do
      image = create(:galleries_image)
      tag = create(:galleries_tag)
      create(:galleries_image_tag, image:, tag:)

      image.remove_tag(tag)

      expect(image.reload.tag_ids).to be_blank
    end
  end

  describe "#video?" do
    it "is true if the content_type starts with 'video/'" do
      image = create(:galleries_image)
      expect(image.file).to receive(:content_type).and_return("video/webm")

      expect(image.video?).to be(true)
    end

    it "is false if the content type does not start with 'video/'" do
      image = create(:galleries_image)
      expect(image.file).to receive(:content_type).and_return("image/png")

      expect(image.video?).to be(false)
    end
  end
end
