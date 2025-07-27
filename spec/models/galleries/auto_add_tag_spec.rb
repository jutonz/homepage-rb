# == Schema Information
#
# Table name: galleries_auto_add_tags
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  auto_add_tag_id :bigint           not null
#  tag_id          :bigint           not null
#
# Indexes
#
#  index_galleries_auto_add_tags_on_auto_add_tag_id             (auto_add_tag_id)
#  index_galleries_auto_add_tags_on_tag_id                      (tag_id)
#  index_galleries_auto_add_tags_on_tag_id_and_auto_add_tag_id  (tag_id,auto_add_tag_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (auto_add_tag_id => galleries_tags.id)
#  fk_rails_...  (tag_id => galleries_tags.id)
#
require "rails_helper"

RSpec.describe Galleries::AutoAddTag do
  it { is_expected.to belong_to(:tag) }
  it { is_expected.to belong_to(:auto_add_tag) }

  describe "validations" do
    it "validates uniqueness of auto_add_tag scoped to tag" do
      tag = create(:galleries_tag)
      auto_add_tag = create(:galleries_tag, gallery: tag.gallery)
      create(:galleries_auto_add_tag, tag:, auto_add_tag:)

      duplicate = build(:galleries_auto_add_tag, tag:, auto_add_tag:)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:auto_add_tag]).to include("has already been taken")
    end

    it "prevents self-reference" do
      tag = create(:galleries_tag)
      auto_add_tag = build(:galleries_auto_add_tag, tag:, auto_add_tag: tag)
      expect(auto_add_tag).not_to be_valid
      expect(auto_add_tag.errors[:auto_add_tag]).to include("cannot be the same as the tag")
    end

    it "prevents circular reference" do
      tag = create(:galleries_tag)
      auto_add_tag = create(:galleries_tag, gallery: tag.gallery)

      # Create tag1 -> tag2
      create(:galleries_auto_add_tag, tag:, auto_add_tag:)

      # Try to create tag2 -> tag1 (circular)
      circular = build(:galleries_auto_add_tag, tag: auto_add_tag, auto_add_tag: tag)
      expect(circular).not_to be_valid
      expect(circular.errors[:auto_add_tag]).to include("would create a circular reference")
    end
  end
end
