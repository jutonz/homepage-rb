require "rails_helper"

RSpec.describe Galleries::TagSearches::ResultActions::AutoAddComponent,
  type: :component do
  it "renders a form that creates the auto-add rule" do
    tag_search = build_stubbed(:galleries_tag_search, :for_auto_add)
    tag = build_stubbed(:galleries_tag, gallery: tag_search.gallery)
    component = described_class.new(tag_search:, tag:)
    add_tag_path = gallery_tag_auto_add_tags_path(
      tag_search.gallery,
      tag_search.auto_add_source,
      auto_add_tag: {auto_add_tag_id: tag.id}
    )

    render_inline(component)

    expect(page).to have_button("Add", exact: true)
    expect(page).to have_css(
      "form[action='#{add_tag_path}'][data-turbo-frame='_top']"
    )
  end
end
