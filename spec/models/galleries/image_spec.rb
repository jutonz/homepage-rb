# == Schema Information
#
# Table name: galleries_images
#
#  id              :bigint           not null, primary key
#  perceptual_hash :vector(64)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  gallery_id      :bigint           not null
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

    it "creates social links" do
      image = create(:galleries_image)
      gallery = image.gallery
      tag = create(:galleries_tag, gallery:, name: "IG:testin")
      expect(tag).to receive(:auto_create_social_links)

      image.add_tag(tag)
    end

    it "automatically adds auto_add_tags when adding a tag" do
      image = create(:galleries_image)
      gallery = image.gallery
      main_tag = create(:galleries_tag, gallery:)
      auto_tag1 = create(:galleries_tag, gallery:)
      auto_tag2 = create(:galleries_tag, gallery:)
      
      create(:galleries_auto_add_tag, tag: main_tag, auto_add_tag: auto_tag1)
      create(:galleries_auto_add_tag, tag: main_tag, auto_add_tag: auto_tag2)

      image.add_tag(main_tag)

      expect(image.reload.tag_ids).to contain_exactly(main_tag.id, auto_tag1.id, auto_tag2.id)
    end

    it "does not duplicate tags when auto-adding" do
      image = create(:galleries_image)
      gallery = image.gallery
      main_tag = create(:galleries_tag, gallery:)
      auto_tag = create(:galleries_tag, gallery:)
      
      create(:galleries_auto_add_tag, tag: main_tag, auto_add_tag: auto_tag)
      image.add_tag(auto_tag) # Add the auto_tag first

      image.add_tag(main_tag) # This should not duplicate auto_tag

      expect(image.reload.tag_ids).to contain_exactly(main_tag.id, auto_tag.id)
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

  describe "#calculate_perceptual_hash!" do
    it "calculates and saves a perceptual_hash" do
      image = create(:galleries_image, perceptual_hash: nil)

      image.calculate_perceptual_hash!

      expect(image.perceptual_hash).to be_present
    end

    it "does nothing if the image is a video" do
      image = create(:galleries_image, :webm, perceptual_hash: nil)

      image.calculate_perceptual_hash!

      expect(image.perceptual_hash).to be_blank
    end
  end

  describe "#simlar_by_phash" do
    it "is empty if the image has no perceptual_hash" do
      image = build(:galleries_image, perceptual_hash: nil)
      expect(image.similar_by_phash).to be_empty
    end

    it "returns similar images" do
      gallery = create(:gallery)
      image1, image2 = create_pair(
        :galleries_image,
        :with_perceptual_hash,
        gallery:
      )
      expect(image1.similar_by_phash.pluck(:id)).to eql([image2.id])
    end

    it "only returns images for the same gallery" do
      image1, _image2 = create_pair(
        :galleries_image,
        :with_perceptual_hash
      )
      expect(image1.similar_by_phash).to be_empty
    end
  end

  describe "#hash_to_vector" do
    it "turns the binary hash into an array" do
      image = build(:galleries_image)

      vector = image.hash_to_vector("001")

      expect(vector).to eql([0, 0, 1])
    end
  end
end
