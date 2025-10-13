require "rails_helper"

RSpec.describe Galleries::RecentTagsQuery, ".call" do
  it "returns all tags applied to images tagged recently" do
    gallery = create(:gallery)
    image1, image2 = create_pair(:galleries_image, gallery:)
    tag1, tag2 = create_pair(:galleries_tag, gallery:)
    image1.add_tag(tag1)
    image2.add_tag(tag2)

    result = described_class.call(
      gallery:,
      excluded_image_ids: nil,
      image_limit: 10
    ).pluck(:id)

    expect(result).to match_array([tag1.id, tag2.id])
  end

  it "can limit the number of images referenced" do
    gallery = create(:gallery)
    image1, image2 = create_pair(:galleries_image, gallery:)
    tag1, tag2 = create_pair(:galleries_tag, gallery:)
    image1.add_tag(tag1)
    image2.add_tag(tag2)

    result = described_class.call(
      gallery:,
      excluded_image_ids: nil,
      image_limit: 1
    ).pluck(:id)

    expect(result).to eql([tag2.id])
  end

  it "can exlude tags for a given image" do
    gallery = create(:gallery)
    image1, image2 = create_pair(:galleries_image, gallery:)
    tag1, tag2 = create_pair(:galleries_tag, gallery:)
    image1.add_tag(tag1)
    image2.add_tag(tag2)

    result = described_class.call(
      gallery:,
      excluded_image_ids: [image2.id],
      image_limit: 10
    ).pluck(:id)

    expect(result).to eql([tag1.id])
  end

  it "doen't include a tag more than once" do
    gallery = create(:gallery)
    image1, image2 = create_pair(:galleries_image, gallery:)
    tag = create(:galleries_tag, gallery:)
    image1.add_tag(tag)
    image2.add_tag(tag)

    result = described_class.call(
      gallery:,
      excluded_image_ids: nil,
      image_limit: 10
    ).pluck(:id)

    expect(result).to eql([tag.id])
  end

  it "orders tags by their most recent usage time" do
    gallery = create(:gallery)
    image1, image2 = create_pair(:galleries_image, gallery:)
    tag_b = create(:galleries_tag, gallery:)
    tag_a = create(:galleries_tag, gallery:)
    image1.add_tag(tag_b)
    image2.add_tag(tag_a)

    result = described_class.call(
      gallery:,
      excluded_image_ids: nil,
      image_limit: 10
    ).pluck(:id)

    expect(result).to eql([tag_a.id, tag_b.id])
  end
end
