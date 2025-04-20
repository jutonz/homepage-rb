require "rails_helper"

RSpec.describe Galleries::ImageComponent, type: :component do
  it "renders a link to the image" do
    image = create(:galleries_image)
    component = described_class.new(image:)
    render_inline(component)

    expect(page).to have_css(
      "a[data-role=image][data-image-id='#{image.id}']"
    )
  end
end
