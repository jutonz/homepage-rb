require "rails_helper"

RSpec.describe Galleries::SimilarImagesComponent, type: :component do
  it "renders a link to the similar images" do
    gallery = create(:gallery)
    image, similar_image = create_pair(:galleries_image, gallery:)
    scope = Galleries::Image.where(id: similar_image)

    component = described_class.new(image:, scope:)
    render_inline(component)

    expect(page).to have_css(
      "a[data-role=image-thumbnail][data-image-id='#{similar_image.id}']"
    )
  end

  it "can customize title" do
    gallery = build_stubbed(:gallery)
    image = build_stubbed(:galleries_image, gallery:)
    scope = Galleries::Image.none

    component = described_class.new(image:, scope:, title: "AAAAAH")
    render_inline(component)

    expect(page).to have_text("AAAAAH")
  end
end
