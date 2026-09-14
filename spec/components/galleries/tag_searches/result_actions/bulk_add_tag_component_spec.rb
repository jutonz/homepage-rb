require "rails_helper"

RSpec.describe Galleries::TagSearches::ResultActions::BulkAddTagComponent,
  type: :component do
  it "renders a button that selects the tag" do
    tag_search = build_stubbed(:galleries_tag_search)
    tag = build_stubbed(:galleries_tag, gallery: tag_search.gallery)
    component = described_class.new(tag_search:, tag:)

    render_inline(component)

    expect(page).to have_button("Select")
    expect(page).to have_selector(
      "button[data-action=" \
      "'gallery-bulk-tag#selectTag tag-search#clearQuery']" \
      "[data-tag-id='#{tag.id}']" \
      "[data-tag-name='#{tag.display_name}']",
      text: "Select"
    )
  end
end
