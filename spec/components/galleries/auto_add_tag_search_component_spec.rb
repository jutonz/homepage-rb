require "rails_helper"

RSpec.describe "Galleries::AutoAddTagSearchComponent", type: :component do
  it "renders a search form with auto-add parameters" do
    tag_search = build_stubbed(:galleries_tag_search, :for_auto_add)
    component = Galleries::AutoAddTagSearchComponent.new(tag_search:)

    render_inline(component)

    expect(page).to have_field("Tag search query")
    expect(page).to have_css(
      "form[action='#{gallery_tag_search_path(tag_search.gallery)}']"
    )
    expect(page).to have_css(
      "input[type='hidden'][name='tag_search[mode]'][value='auto_add']",
      visible: :all
    )
    expect(page).to have_css(
      "input[type='hidden'][name='tag_search[auto_add_source_id]']" \
        "[value='#{tag_search.auto_add_source.id}']",
      visible: :all
    )
  end

  it "starts with an empty results area and no select" do
    tag_search = build_stubbed(:galleries_tag_search, :for_auto_add)
    component = Galleries::AutoAddTagSearchComponent.new(tag_search:)

    render_inline(component)

    expect(page).to have_css("turbo-frame#tag-search-results")
    expect(page).not_to have_css("select")
  end

  it "does not offer to create a new tag" do
    tag_search = build_stubbed(
      :galleries_tag_search,
      :for_auto_add,
      query: "new tag"
    )
    component = Galleries::AutoAddTagSearchComponent.new(tag_search:)

    render_inline(component)

    expect(page).not_to have_button("Create tag 'new tag'")
  end
end
