require "rails_helper"

RSpec.describe Galleries::SimilarImagesComponent, type: :component do
  it "renders a link to the similar images" do
    gallery = create(:gallery)
    image, similar_image = create_pair(:galleries_image, gallery:)
    tag = create(:galleries_tag, gallery:)
    [image, similar_image].each { it.add_tag(tag) }

    component = described_class.new(image:)
    render_inline(component)

    expect(page).to have_css(
      "a[data-role=image-thumbnail][data-image-id='#{similar_image.id}']"
    )
  end
end
