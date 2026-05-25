require "rails_helper"

RSpec.describe Galleries::RelatedTagsQuery, ".call" do
  it "returns tags that co-occur on the source tag's images" do
    gallery = create(:gallery)
    source, partner, unrelated =
      create_list(:galleries_tag, 3, gallery:)
    image1, image2 = create_list(:galleries_image, 2, gallery:)
    [image1, image2].each { it.add_tag(source, partner) }
    create(:galleries_image, gallery:).add_tag(unrelated)

    result = described_class.call(tag: source)

    expect(result.map(&:tag)).to eql([partner])
  end

  it "excludes the source tag itself" do
    gallery = create(:gallery)
    source = create(:galleries_tag, gallery:)
    image = create(:galleries_image, gallery:)
    image.add_tag(source)

    result = described_class.call(tag: source)

    expect(result.map(&:tag)).to be_empty
  end

  it "orders by shared image count, most-shared first" do
    gallery = create(:gallery)
    source, frequent, infrequent =
      create_list(:galleries_tag, 3, gallery:)
    img1, img2, img3 = create_list(:galleries_image, 3, gallery:)
    [img1, img2, img3].each { it.add_tag(source, frequent) }
    img1.add_tag(infrequent)

    result = described_class.call(tag: source).map(&:tag)

    expect(result).to eql([frequent, infrequent])
  end

  it "ranks by co-occurrence count, not rarity" do
    gallery = create(:gallery)
    source, frequent_partner, rare_partner =
      create_list(:galleries_tag, 3, gallery:)
    shared1, shared2 = create_list(:galleries_image, 2, gallery:)
    # source co-occurs with frequent_partner on 2 images, rare_partner on 1
    shared1.add_tag(source, frequent_partner, rare_partner)
    shared2.add_tag(source, frequent_partner)
    # frequent_partner also appears on 2 source-less images, making it
    # common; rare_partner appears nowhere else, making it rare.
    create_list(:galleries_image, 2, gallery:)
      .each { it.add_tag(frequent_partner) }

    result = described_class.call(tag: source).map(&:tag)

    expect(result).to eql([frequent_partner, rare_partner])
  end

  it "reports shared_count per related tag" do
    gallery = create(:gallery)
    source, partner = create_pair(:galleries_tag, gallery:)
    img1, img2 = create_list(:galleries_image, 2, gallery:)
    [img1, img2].each { it.add_tag(source, partner) }

    result = described_class.call(tag: source)

    expect(result.first.shared_count).to eql(2)
  end

  it "scopes to the source tag's gallery" do
    gallery = create(:gallery)
    other_gallery = create(:gallery)
    source = create(:galleries_tag, gallery:)
    same_gallery_partner = create(:galleries_tag, gallery:)
    other_gallery_partner = create(:galleries_tag, gallery: other_gallery)
    shared_image = create(:galleries_image, gallery:)
    shared_image.add_tag(source, same_gallery_partner)
    create(:galleries_image, gallery: other_gallery)
      .add_tag(other_gallery_partner)

    result = described_class.call(tag: source).map(&:tag)

    expect(result).to eql([same_gallery_partner])
  end

  it "limits to 10 results" do
    gallery = create(:gallery)
    source = create(:galleries_tag, gallery:)
    partners = create_list(:galleries_tag, 12, gallery:)
    image = create(:galleries_image, gallery:)
    image.add_tag(source, *partners)

    result = described_class.call(tag: source)

    expect(result.size).to eql(10)
  end

  it "returns an empty array when there are no co-occurrences" do
    gallery = create(:gallery)
    source = create(:galleries_tag, gallery:)

    result = described_class.call(tag: source)

    expect(result).to be_empty
  end
end
