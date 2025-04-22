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
  it { is_expected.to have_many(:image_similar_images).dependent(:delete_all) }
  it { is_expected.to have_many(:similar_images) }

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
      tag = create(:galleries_tag)

      image.add_tag(tag)

      expect(image.reload.tag_ids).to eql([tag.id])
    end

    it "enqueues UpdateSimilarImagesJob" do
      image = create(:galleries_image)
      tag = create(:galleries_tag)
      expect(Galleries::UpdateSimilarImagesJob)
        .to receive(:perform_later)
        .with(image)

      image.add_tag(tag)
    end

    it "does not enqueue UpdateSimilarImagesJob if the tag added is 'tagging needed'" do
      image = create(:galleries_image)
      tag = Galleries::Tag.tagging_needed(image.gallery)
      expect(Galleries::UpdateSimilarImagesJob)
        .not_to receive(:perform_later)

      image.add_tag(tag)
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

    it "enqueues UpdateSimilarImagesJob" do
      image = create(:galleries_image)
      tag = create(:galleries_tag)
      create(:galleries_image_tag, image:, tag:)
      expect(Galleries::UpdateSimilarImagesJob)
        .to receive(:perform_later)
        .with(image)

      image.remove_tag(tag)
    end

    it "does not enqueue UpdateSimilarImagesJob if the tag removed is 'tagging needed'" do
      image = create(:galleries_image)
      tag = Galleries::Tag.tagging_needed(image.gallery)
      create(:galleries_image_tag, image:, tag:)
      expect(Galleries::UpdateSimilarImagesJob)
        .not_to receive(:perform_later)

      image.remove_tag(tag)
    end
  end
end
