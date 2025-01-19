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
  it { is_expected.to have_many(:image_tags) }
  it { is_expected.to have_many(:images) }

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
end
