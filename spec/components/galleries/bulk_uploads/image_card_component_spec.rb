require "rails_helper"

RSpec.describe Galleries::BulkUploads::ImageCardComponent,
  type: :component do
  it "renders a processing spinner when image is processing" do
    image = build_stubbed(:galleries_image, processing: true)

    render_inline(described_class.new(image:))

    expect(page).to have_css("[data-role=processing-image-card]")
    expect(page).not_to have_css("[data-role=image-thumbnail]")
  end

  it "renders the image thumbnail when processing is done" do
    image = create(:galleries_image, processing: false)

    render_inline(described_class.new(image:))

    expect(page).to have_css(
      "[data-role=image-thumbnail][data-image-id='#{image.id}']"
    )
    expect(page).not_to have_css("[data-role=processing-image-card]")
  end

  it "wraps the card in a unique dom id" do
    image = build_stubbed(:galleries_image, processing: true)

    render_inline(described_class.new(image:))

    expect(page).to have_css("##{ActionView::RecordIdentifier.dom_id(image, :card)}")
  end
end
