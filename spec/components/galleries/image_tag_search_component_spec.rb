require "rails_helper"

RSpec.describe Galleries::ImageTagSearchComponent, type: :component do
  it "renders" do
    tag_search = build_stubbed(:galleries_tag_search, :with_image)
    component = described_class.new(tag_search:)
    render_inline(component)

    expect(page).to have_css("h3", text: "Add tag")
  end

  it "includes recently used tags" do
    tag_search = create(:galleries_tag_search, :with_image)
    gallery = tag_search.gallery
    other_image = create(:galleries_image, gallery:)
    tag = create(:galleries_tag, gallery:)
    other_image.add_tag(tag)
    component = described_class.new(tag_search:)
    render_inline(component)

    expect(page).to have_css("h4", text: "Recently used tags")
    expect(page).to have_text(tag.display_name)
    expect(page).to have_button("Add tag")
  end
end
