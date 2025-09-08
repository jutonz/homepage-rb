require "rails_helper"

RSpec.describe Galleries::SocialLinksCreator do
  describe ".call" do
    it "creates an insta link for a tag prefixed with IG:" do
      tag = create(:galleries_tag, name: "IG:testin")

      result_tag = described_class.call(tag)

      expect(result_tag).to eq(tag)
      expect(tag.reload.social_media_links.length).to eq(1)
      expect(tag.social_media_links.first).to have_attributes(
        platform: "instagram",
        username: "testin"
      )
    end

    it "creates a tiktok link for a tag prefixed with TT:" do
      tag = create(:galleries_tag, name: "TT:testin")

      result_tag = described_class.call(tag)

      expect(result_tag).to eq(tag)
      expect(tag.reload.social_media_links.length).to eq(1)
      expect(tag.social_media_links.first).to have_attributes(
        platform: "tiktok",
        username: "testin"
      )
    end

    it "creates a reddit link for a tag prefixed with RD:" do
      tag = create(:galleries_tag, name: "RD:testin")

      result_tag = described_class.call(tag)

      expect(result_tag).to eq(tag)
      expect(tag.reload.social_media_links.length).to eq(1)
      expect(tag.social_media_links.first).to have_attributes(
        platform: "reddit",
        username: "testin"
      )
    end

    it "returns the tag unchanged for tags without recognized prefixes" do
      tag = create(:galleries_tag, name: "regular_tag")

      result_tag = described_class.call(tag)

      expect(result_tag).to eq(tag)
      expect(tag.reload.social_media_links.length).to eq(0)
    end

    describe "duplicate detection within same gallery" do
      it "returns existing tag when duplicate social link exists in same gallery" do
        gallery = create(:gallery)
        existing_tag = create(:galleries_tag, name: "person_on_instagram", gallery:)
        create(:galleries_social_media_link,
          tag: existing_tag,
          platform: "instagram",
          username: "duplicate")

        new_tag = create(:galleries_tag, name: "IG:duplicate", gallery:)

        result_tag = described_class.call(new_tag)

        expect(result_tag).to eq(existing_tag)
        expect(result_tag).not_to eq(new_tag)
      end

      it "creates new social link when no duplicate exists in same gallery" do
        gallery = create(:gallery)
        tag = create(:galleries_tag, name: "IG:unique", gallery:)

        result_tag = described_class.call(tag)

        expect(result_tag).to eq(tag)
        expect(tag.reload.social_media_links.length).to eq(1)
        expect(tag.social_media_links.first).to have_attributes(
          platform: "instagram",
          username: "unique"
        )
      end

      it "ignores duplicates in different galleries" do
        gallery1 = create(:gallery)
        gallery2 = create(:gallery)

        existing_tag = create(:galleries_tag, name: "IG:same", gallery: gallery1)
        create(:galleries_social_media_link,
          tag: existing_tag,
          platform: "instagram",
          username: "same")

        new_tag = create(:galleries_tag, name: "IG:same", gallery: gallery2)

        result_tag = described_class.call(new_tag)

        expect(result_tag).to eq(new_tag)
        # No social media link should be created due to global uniqueness constraint
        expect(new_tag.reload.social_media_links.length).to eq(0)
      end
    end
  end
end
