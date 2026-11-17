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

  it "renders a poster image with a play overlay for videos" do
    image = create(:galleries_image, :webm)
    image.poster.processed
    component = described_class.new(image: image.reload)

    render_inline(component)

    expect(page).to have_css("img")
    expect(page).to have_css("[data-role=video-overlay]")
    expect(page).not_to have_css("[data-role=video-poster-placeholder]")
    expect(page).not_to have_css("video")
  end

  it "renders a placeholder for videos without a generated poster" do
    image = create(:galleries_image, :webm)
    component = described_class.new(image:)

    render_inline(component)

    expect(page).to have_css("[data-role=video-poster-placeholder]")
    expect(page).to have_css("[data-role=video-overlay]")
    expect(page).not_to have_css("img")
  end
end
