require "rails_helper"

RSpec.describe Galleries::UpdateSimilarImages, ".call" do
  it "deletes any existing SimilarImages" do
    gallery = create(:gallery)
    image1, image2 = create_pair(:galleries_image, gallery:)
    similar_image = create(
      :galleries_image_similar_image,
      parent_image: image1,
      image: image2
    )

    described_class.new(image: image1).call

    expect(
      Galleries::ImageSimilarImage.where(id: similar_image.id)
    ).not_to exist
  end

  it "creates new ImageSimilarImages" do
    gallery = create(:gallery)
    image1, image2 = create_pair(:galleries_image, gallery:)
    expect(Galleries::SimilarImages)
      .to receive(:new)
      .with(image: image1)
      .and_return([image2])

    described_class.new(image: image1).call

    expect(Galleries::ImageSimilarImage.last).to have_attributes(
      position: 0,
      image_id: image2.id,
      parent_image_id: image1.id
    )
    expect(image1.similar_image_ids).to eql([image2.id])
  end

  it "sets the position of the new images according to their ranking" do
    gallery = create(:gallery)
    image1, image2, image3 = create_list(:galleries_image, 3, gallery:)
    expect(Galleries::SimilarImages)
      .to receive(:new)
      .with(image: image1)
      .and_return([image3, image2])

    described_class.new(image: image1).call

    expect(image1.similar_image_ids).to eql([image3.id, image2.id])
  end
end
