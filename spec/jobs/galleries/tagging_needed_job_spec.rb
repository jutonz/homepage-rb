require "rails_helper"

RSpec.describe Galleries::TaggingNeededJob, "#perform" do
  it "adds 'tagging needed' to images" do
    gallery = create(:gallery)
    image = create(:galleries_image, gallery:)

    described_class.new.perform

    expect(image.tags.pluck(:name)).to eql(["tagging needed"])
  end

  it "does not add the tag to images which have tags" do
    gallery = create(:gallery)
    image = create(:galleries_image, gallery:)
    some_other_tag = create(:galleries_tag, gallery:)
    image.add_tag(some_other_tag)

    described_class.new.perform

    expect(image.tags.pluck(:name)).not_to include("tagging needed")
  end
end
