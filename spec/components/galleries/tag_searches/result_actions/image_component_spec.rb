require "rails_helper"

RSpec.describe Galleries::TagSearches::ResultActions::ImageComponent,
  type: :component do
  it "renders a button that tags the image" do
    tag_search = build_stubbed(:galleries_tag_search, :with_image)
    tag = build_stubbed(:galleries_tag, gallery: tag_search.gallery)
    component = described_class.new(tag_search:, tag:)
    add_tag_path = gallery_image_tags_path(
      tag_search.gallery, tag_search.image, tag_id: tag.id
    )

    render_inline(component)

    expect(page).to have_selector("form[action='#{add_tag_path}']")
    expect(page).to have_button("Add tag", exact: true)
  end
end
