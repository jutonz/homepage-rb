require "rails_helper"

RSpec.describe SimilarImagesComponent, type: :component do
  it "renders a link to the similar images" do
    gallery = create(:gallery)
    image, similar_image = create_pair(:galleries_image, gallery:)
    component = described_class.new(
      image:,
      similar_images: [similar_image]
    )
    render_inline(component)

    expect(page).to have_css(
      "a[data-role=image][data-image-id='#{similar_image.id}']"
    )
  end
end
