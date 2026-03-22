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

  it "in image mode, renders a button that tags the image" do
    tag_search = create(:galleries_tag_search, :with_image, query: "Hello")
    gallery = tag_search.gallery
    image = tag_search.image
    tag = create(:galleries_tag, gallery:, name: "Hello World")
    component = described_class.new(tag_search:, mode: :image)
    render_inline(component)
    add_tag_path =
      Rails.application.routes.url_helpers.gallery_image_tags_path(
        gallery,
        image,
        tag_id: tag.id
      )

    expect(page).to have_selector(
      "form[action='#{add_tag_path}']"
    )
    expect(page).to have_button("Add tag")
  end

  it "in gallery mode, renders a link to add the tag as a filter" do
    tag_search = create(:galleries_tag_search, query: "Hello")
    gallery = tag_search.gallery
    tag = create(:galleries_tag, gallery:, name: "Hello World")
    component = described_class.new(tag_search:, mode: :gallery)

    with_request_url(
      Rails.application.routes.url_helpers.gallery_path(
        gallery,
        tag_search: {query: tag_search.query},
        tag_ids: ["3"],
        select: "true",
        selected_ids: ["7"],
        page: "2"
      )
    ) do
      render_inline(component)
    end

    expect(page).to have_link(
      "Add",
      href: Rails.application.routes.url_helpers.gallery_path(
        gallery,
        page: "2",
        select: "true",
        selected_ids: ["7"],
        tag_ids: ["3", tag.id.to_s],
        tag_search: {query: tag_search.query}
      )
    )
  end

  it "in bulk_add_tag mode, renders a button to select the tag" do
    tag_search = create(:galleries_tag_search, query: "Hello")
    gallery = tag_search.gallery
    tag = create(:galleries_tag, gallery:, name: "Hello World")
    component = described_class.new(tag_search:, mode: :bulk_add_tag)
    render_inline(component)

    expect(page).to have_button("Select")
    expect(page).to have_selector(
      "button[data-action='gallery-bulk-tag#selectTag']" \
      "[data-tag-id='#{tag.id}']" \
      "[data-tag-name='#{tag.display_name}']",
      text: "Select"
    )
  end

  it "in gallery mode, does not render Add for a selected tag" do
    tag_search = create(:galleries_tag_search, query: "Hello")
    gallery = tag_search.gallery
    selected_tag = create(:galleries_tag, gallery:, name: "Hello World")
    available_tag = create(:galleries_tag, gallery:, name: "Hello There")
    component = described_class.new(tag_search:, mode: :gallery)

    with_request_url(
      Rails.application.routes.url_helpers.gallery_path(
        gallery,
        tag_ids: [selected_tag.id],
        page: "2"
      )
    ) do
      render_inline(component)
    end

    selected_result = page.find(
      "[data-role=tag-search-result]",
      text: selected_tag.display_name
    )
    available_result = page.find(
      "[data-role=tag-search-result]",
      text: available_tag.display_name
    )

    within(selected_result) do
      expect(page).not_to have_link("Add")
    end

    within(available_result) do
      expect(page).to have_link("Add")
    end
  end

  it "if a query is present, has a button to create a new tag" do
    tag_search = build_stubbed(
      :galleries_tag_search,
      :with_image,
      query: "Hello"
    )
    component = described_class.new(tag_search:)
    render_inline(component)

    expect(page).to have_button("Create tag '#{tag_search.query}'")
  end

  it "if no image is present, does not have a button to create a new tag" do
    tag_search = build_stubbed(:galleries_tag_search, query: "Hello")
    component = described_class.new(tag_search:)
    render_inline(component)

    expect(page).not_to have_button("Create tag '#{tag_search.query}'")
  end

  it "if no query is present, does not have a button to create a new tag" do
    tag_search = build_stubbed(:galleries_tag_search, :with_image, query: "")
    component = described_class.new(tag_search:)
    render_inline(component)

    expect(page).not_to have_button("Create tag '#{tag_search.query}'")
  end
end
