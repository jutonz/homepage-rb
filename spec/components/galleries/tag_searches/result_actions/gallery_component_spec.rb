require "rails_helper"

RSpec.describe Galleries::TagSearches::ResultActions::GalleryComponent,
  type: :component do
  it "renders a link that adds the tag as a filter" do
    tag_search = build_stubbed(:galleries_tag_search)
    tag = build_stubbed(:galleries_tag, gallery: tag_search.gallery)
    component = described_class.new(tag_search:, tag:)

    with_request_url(
      gallery_path(
        tag_search.gallery,
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
      href: gallery_path(
        tag_search.gallery,
        page: "2",
        select: "true",
        selected_ids: ["7"],
        tag_ids: ["3", tag.id.to_s],
        tag_search: {query: tag_search.query}
      )
    )
    expect(page).to have_css("a.button[data-turbo-frame='_top']", text: "Add")
  end

  it "does not render when the tag is already selected" do
    tag_search = build_stubbed(:galleries_tag_search)
    tag = build_stubbed(:galleries_tag, gallery: tag_search.gallery)
    component = described_class.new(tag_search:, tag:)

    with_request_url(gallery_path(tag_search.gallery, tag_ids: [tag.id])) do
      rendered = render_inline(component)

      expect(rendered.to_html).to eq("")
    end
  end
end
