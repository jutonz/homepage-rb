require "rails_helper"

RSpec.describe Galleries::ImageThumbnailComponent, type: :component do
  it "renders a link to the image" do
    image = create(:galleries_image)
    component = described_class.new(image:)
    render_inline(component)

    expect(page).to have_css(
      "a[data-role=image-thumbnail][data-image-id='#{image.id}']"
    )
  end

  it "displays thumbnails for videos" do
    image = create(:galleries_image, :webm)
    component = described_class.new(image:)
    render_inline(component)

    expect(page).to have_css(
      "video[preload=metadata]"
    )
  end
end
