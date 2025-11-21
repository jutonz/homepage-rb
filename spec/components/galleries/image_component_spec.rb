require "rails_helper"

RSpec.describe Galleries::ImageComponent, type: :component do
  it "includes a data-image-id attr" do
    image = create(:galleries_image)
    component = described_class.new(image:)
    render_inline(component)

    expect(page).to have_css(
      "div[data-role=image][data-image-id='#{image.id}']"
    )
  end

  it "if the image is an image, renders a link to the image" do
    image = create(:galleries_image, :with_real_file)
    component = described_class.new(image:)
    render_inline(component)

    expect(page).to have_link do |link|
      link.native.attr("href").start_with?("/rails/active_storage/blobs/redirect/")
    end
  end

  it "if the image is a video, renders a video tag" do
    image = create(:galleries_image, :webm)
    component = described_class.new(image:)
    render_inline(component)

    expect(page).to have_css(
      "video[controls=controls][preload=metadata]"
    )
  end
end
