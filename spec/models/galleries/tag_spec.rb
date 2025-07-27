# == Schema Information
#
# Table name: galleries_tags
#
#  id               :bigint           not null, primary key
#  image_tags_count :integer          default(0), not null
#  name             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  gallery_id       :bigint           not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_galleries_tags_on_gallery_id           (gallery_id)
#  index_galleries_tags_on_gallery_id_and_name  (gallery_id,name) UNIQUE
#  index_galleries_tags_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (gallery_id => galleries.id)
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Galleries::Tag, type: :model do
  it { is_expected.to belong_to(:gallery) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:image_tags).dependent(:destroy) }
  it { is_expected.to have_many(:images) }
  it { is_expected.to have_many(:auto_add_tag_associations).dependent(:destroy) }
  it { is_expected.to have_many(:auto_add_tags) }

  it { is_expected.to validate_presence_of(:name) }
  it do
    expect(build(:galleries_tag))
      .to validate_uniqueness_of(:name)
      .scoped_to(:gallery_id)
  end

  describe ".tagging_needed" do
    it "if a 'tagging needed' tag already exists, returns it" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:, name: "tagging needed")

      result = described_class.tagging_needed(gallery)

      expect(result).to eql(tag)
    end

    it "creates and returns a 'tagging needed' tag if it doesn't exist" do
      gallery = create(:gallery)

      tag = described_class.tagging_needed(gallery)

      expect(tag).to have_attributes(
        name: "tagging needed",
        user: gallery.user
      )
      expect(gallery.tags.size).to eql(1)
    end
  end

  describe "#display_name" do
    it "is the name plus the number of times it's been used" do
      gallery = create(:gallery)
      tag = create(:galleries_tag, gallery:, name: "blah")
      image = create(:galleries_image, gallery:)
      image.add_tag(tag)

      expect(tag.display_name).to eql("blah (1)")
    end
  end

  describe "#tagging_needed?" do
    it "is true if the name is 'tagging needed'" do
      tag = build(:galleries_tag, :tagging_needed)
      expect(tag.tagging_needed?).to be(true)
    end

    it "is false if the name is not 'tagging needed'" do
      tag = build(:galleries_tag, name: "else")
      expect(tag.tagging_needed?).to be(false)
    end
  end

  describe "#auto_create_social_links" do
    it "creates an insta link for a tag prefixed with IG:" do
      tag = create(:galleries_tag, name: "IG:testin")

      tag.auto_create_social_links

      expect(tag.reload.social_media_links.length).to eq(1)
      expect(tag.social_media_links.first).to have_attributes(
        platform: "instagram",
        username: "testin"
      )
    end

    it "creates a tiktok link for a tag prefixed with TT:" do
      tag = create(:galleries_tag, name: "TT:testin")

      tag.auto_create_social_links

      expect(tag.reload.social_media_links.length).to eq(1)
      expect(tag.social_media_links.first).to have_attributes(
        platform: "tiktok",
        username: "testin"
      )
    end
  end

  describe "#available_auto_add_tags" do
    it "returns other tags in the same gallery" do
      gallery = create(:gallery)
      tag1 = create(:galleries_tag, gallery:, name: "tag1")
      create(:galleries_tag, gallery:, name: "tag2")
      create(:galleries_tag, gallery:, name: "tag3")

      available = tag1.available_auto_add_tags

      expect(available.pluck(:name)).to contain_exactly("tag2", "tag3")
    end

    it "excludes itself from available tags" do
      gallery = create(:gallery)
      tag1 = create(:galleries_tag, gallery:, name: "tag1")
      create(:galleries_tag, gallery:, name: "tag2")

      available = tag1.available_auto_add_tags

      expect(available.pluck(:name)).not_to include("tag1")
    end

    it "excludes already configured auto-add tags" do
      gallery = create(:gallery)
      tag1 = create(:galleries_tag, gallery:, name: "tag1")
      tag2 = create(:galleries_tag, gallery:, name: "tag2")
      create(:galleries_tag, gallery:, name: "tag3")
      create(:galleries_auto_add_tag, tag: tag1, auto_add_tag: tag2)

      available = tag1.available_auto_add_tags

      expect(available.pluck(:name)).to contain_exactly("tag3")
    end

    it "excludes tags from other galleries" do
      gallery1 = create(:gallery)
      gallery2 = create(:gallery)
      tag1 = create(:galleries_tag, gallery: gallery1, name: "tag1")
      create(:galleries_tag, gallery: gallery1, name: "tag2")
      create(:galleries_tag, gallery: gallery2, name: "tag3")

      available = tag1.available_auto_add_tags

      expect(available.pluck(:name)).to contain_exactly("tag2")
    end
  end
end
