require "rails_helper"

RSpec.describe Galleries::SimilarImagesQuery, ".call" do
  it "returns images with the same tag" do
    gallery = create(:gallery)
    image1, image2, _image3 = create_list(:galleries_image, 3, gallery:)
    tag = create(:galleries_tag, gallery:)
    [image1, image2].each { it.add_tag(tag) }

    result = described_class.call(image: image1).to_a

    expect(result).to eql([image2])
  end

  it "orders images by the number of related tags" do
    gallery = create(:gallery)
    image1, image2, image3 = create_list(:galleries_image, 3, gallery:)
    tag1, tag2 = create_pair(:galleries_tag, gallery:)
    [image1, image3].each { it.add_tag(tag1, tag2) }
    [image1, image2].each { it.add_tag(tag1) }

    result = described_class.call(image: image1).pluck(:id)

    expect(result).to eql([image3.id, image2.id])
  end

  it "gives higher weight to less common tags" do
    gallery = create(:gallery)
    image1, image2, image3, image4 = create_list(:galleries_image, 4, gallery:)
    common_tag, rare_tag = create_pair(:galleries_tag, gallery:)
    [image1, image2, image4].each { it.add_tag(common_tag) }
    [image1, image3].each { it.add_tag(rare_tag) }

    result = described_class.call(image: image1).pluck(:id)

    # image1 shares one tag with both image2 and image3, and the one shared
    # with image3 is also shared with image4, making it less rare.
    expect(result).to eql([image3.id, image2.id, image4.id])
  end
end
