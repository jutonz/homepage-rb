require "rails_helper"

RSpec.describe Galleries::TagSearches::ResultsComponent, type: :component do
  it "renders search results" do
    tag_search = create(:galleries_tag_search, :with_image, query: "Hello")
    gallery = tag_search.gallery
    tag = create(:galleries_tag, gallery:, name: "Hello World")
    component = described_class.new(tag_search:)
    render_inline(component)

    search_result = page.find(
      "[data-role=tag-search-result]",
      text: tag.display_name
    )
    within(search_result) do
      expect(page).to have_button("Add tag")
    end
  end

  it "in image mode, renders a button to tag the image"
  it "in gallery mode, renders a button to search for the tag"
  it "in bulk_add_tag mode, renders a button to select the tag"

  it "if a query is present, has a button to create a new tag" do
    tag_search = build_stubbed(:galleries_tag_search, :with_image, query: "Hello")
    component = described_class.new(tag_search:)
    render_inline(component)

    expect(page).to have_button("Create tag '#{tag_search.query}'")
  end

  it "if no query is present, does not have a button to create a new tag" do
    tag_search = build_stubbed(:galleries_tag_search, :with_image, query: "")
    component = described_class.new(tag_search:)
    render_inline(component)

    expect(page).not_to have_button("Create tag '#{tag_search.query}'")
  end
end
