require "rails_helper"

RSpec.describe Galleries::SocialLinksCreator do
  describe ".call" do
    it "creates an insta link for a tag prefixed with IG:" do
      tag = create(:galleries_tag, name: "IG:testin")

      described_class.call(tag)

      expect(tag.reload.social_media_links.length).to eq(1)
      expect(tag.social_media_links.first).to have_attributes(
        platform: "instagram",
        username: "testin"
      )
    end

    it "creates a tiktok link for a tag prefixed with TT:" do
      tag = create(:galleries_tag, name: "TT:testin")

      described_class.call(tag)

      expect(tag.reload.social_media_links.length).to eq(1)
      expect(tag.social_media_links.first).to have_attributes(
        platform: "tiktok",
        username: "testin"
      )
    end

    it "creates a reddit link for a tag prefixed with RD:" do
      tag = create(:galleries_tag, name: "RD:testin")

      described_class.call(tag)

      expect(tag.reload.social_media_links.length).to eq(1)
      expect(tag.social_media_links.first).to have_attributes(
        platform: "reddit",
        username: "testin"
      )
    end

    it "does nothing for tags without recognized prefixes" do
      tag = create(:galleries_tag, name: "regular_tag")

      described_class.call(tag)

      expect(tag.reload.social_media_links.length).to eq(0)
    end

    it "classifies an IG: tag as subject" do
      tag = create(:galleries_tag, name: "IG:testin")

      described_class.call(tag)

      expect(tag.reload.classification).to eq("subject")
    end

    it "does not classify a TT: tag as subject" do
      tag = create(:galleries_tag, name: "TT:testin")

      described_class.call(tag)

      expect(tag.reload.classification).to eq("none")
    end

    it "does not classify an RD: tag as subject" do
      tag = create(:galleries_tag, name: "RD:testin")

      described_class.call(tag)

      expect(tag.reload.classification).to eq("none")
    end

    it "skips update! when tag is already classified as subject" do
      tag = create(
        :galleries_tag,
        name: "IG:testin",
        classification: :subject
      )
      allow(tag).to receive(:update!)

      described_class.call(tag)

      expect(tag).not_to have_received(:update!)
    end
  end
end
