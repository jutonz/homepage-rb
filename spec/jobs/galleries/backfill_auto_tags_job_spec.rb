require "rails_helper"

RSpec.describe Galleries::BackfillAutoTagsJob do
  describe "#perform" do
    it "adds the auto-tag to images that already have the main tag" do
      gallery = create(:gallery)
      main_tag = create(:galleries_tag, gallery:)
      auto_tag = create(:galleries_tag, gallery:)
      image = create(:galleries_image, gallery:)
      image.add_tag(main_tag)

      auto_add_tag = create(:galleries_auto_add_tag,
        tag: main_tag,
        auto_add_tag: auto_tag)

      described_class.new.perform(auto_add_tag)

      expect(image.reload.tags).to include(main_tag, auto_tag)
    end

    it "does not affect images without the main tag" do
      gallery = create(:gallery)
      main_tag = create(:galleries_tag, gallery:)
      auto_tag = create(:galleries_tag, gallery:)
      other_tag = create(:galleries_tag, gallery:)
      image = create(:galleries_image, gallery:)
      image.add_tag(other_tag)

      auto_add_tag = create(:galleries_auto_add_tag,
        tag: main_tag,
        auto_add_tag: auto_tag)

      described_class.new.perform(auto_add_tag)

      expect(image.reload.tags).to eq([other_tag])
    end
  end
end
