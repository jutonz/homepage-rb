require "rails_helper"

RSpec.describe Galleries::TagSearches::FormComponent, type: :component do
  it "submits to the supplied search path" do
    tag_search = build_stubbed(:galleries_tag_search, :with_image)
    search_path = gallery_image_tag_search_path(
      tag_search.gallery, tag_search.image
    )
    component = described_class.new(tag_search:, search_path:)

    render_inline(component)

    expect(page).to have_css("turbo-frame#tag-search-form")
    expect(page).to have_css("form[action='#{search_path}'][method='get']")
    expect(page).to have_field("Tag search query")
    expect(page).to have_button("Search")
  end

  it "submits to a gallery path when the caller supplies one" do
    tag_search = build_stubbed(:galleries_tag_search)
    search_path = gallery_tag_search_path(tag_search.gallery)
    component = described_class.new(tag_search:, search_path:)

    render_inline(component)

    expect(page).to have_css("form[action='#{search_path}'][method='get']")
  end
end
