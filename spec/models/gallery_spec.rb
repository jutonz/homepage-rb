# == Schema Information
#
# Table name: galleries
#
#  id         :bigint           not null, primary key
#  hidden_at  :datetime
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_galleries_on_name     (name) UNIQUE
#  index_galleries_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Gallery do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:images) }
  it { is_expected.to have_many(:tags) }

  it { is_expected.to validate_presence_of(:name) }

  describe "uniqueness validation" do
    subject { build(:gallery) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  it "has a valid factory" do
    expect(create(:gallery)).to be_valid
  end

  describe ".visible" do
    it "does not include hidden galleries" do
      visible = create(:gallery)
      _hidden = create(:gallery, :hidden)

      result = described_class.visible.pluck(:id)

      expect(result).to eql([visible.id])
    end
  end

  describe ".hidden" do
    it "only includes hidden galleries" do
      _visible = create(:gallery)
      hidden = create(:gallery, :hidden)

      result = described_class.hidden.pluck(:id)

      expect(result).to eql([hidden.id])
    end
  end

  describe "#recently_used_tags" do
    it "returns all tags applied to images tagged recently" do
      gallery = create(:gallery)
      image1, image2 = create_pair(:galleries_image, gallery:)
      tag1, tag2 = create_pair(:galleries_tag, gallery:)
      image1.add_tag(tag1)
      image2.add_tag(tag2)

      result = gallery.recently_used_tags.pluck(:id)

      expect(result).to eql([tag1.id, tag2.id])
    end

    it "can limit the number of images referenced" do
      gallery = create(:gallery)
      image1, image2 = create_pair(:galleries_image, gallery:)
      tag1, tag2 = create_pair(:galleries_tag, gallery:)
      image1.add_tag(tag1)
      image2.add_tag(tag2)

      result = gallery.recently_used_tags(image_limit: 1).pluck(:id)

      expect(result).to eql([tag2.id])
    end

    it "can exlude tags for a given image" do
      gallery = create(:gallery)
      image1, image2 = create_pair(:galleries_image, gallery:)
      tag1, tag2 = create_pair(:galleries_tag, gallery:)
      image1.add_tag(tag1)
      image2.add_tag(tag2)

      result = gallery.recently_used_tags(excluded_image_ids: [image2.id]).pluck(:id)

      expect(result).to eql([tag1.id])
    end

    it "doen't include a tag more than once" do
      gallery = create(:gallery)
      image1, image2 = create_pair(:galleries_image, gallery:)
      tag = create(:galleries_tag, gallery:)
      image1.add_tag(tag)
      image2.add_tag(tag)

      result = gallery.recently_used_tags.pluck(:id)

      expect(result).to eql([tag.id])
    end

    it "orders tags by name" do
      gallery = create(:gallery)
      image1, image2 = create_pair(:galleries_image, gallery:)
      tag_b = create(:galleries_tag, gallery:, name: "Tag B")
      tag_a = create(:galleries_tag, gallery:, name: "Tag A")
      image1.add_tag(tag_b)
      image2.add_tag(tag_a)

      result = gallery.recently_used_tags.pluck(:id)

      expect(result).to eql([tag_a.id, tag_b.id])
    end
  end
end
