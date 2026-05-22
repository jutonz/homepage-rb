require "rails_helper"

RSpec.describe Galleries::RelatedTagsComponent, type: :component do
  it "renders nothing when there are no related tags" do
    component = described_class.new(related_tags: [])

    render_inline(component)

    expect(page).not_to have_text("Related tags")
    expect(page).not_to have_css("[data-role=related-tags]")
  end

  it "renders a heading when related tags are present" do
    gallery = build_stubbed(:gallery)
    tag = build_stubbed(:galleries_tag, gallery:, name: "Nature")
    row = Galleries::RelatedTagsQuery::Result.new(
      tag:,
      shared_count: 3
    )

    render_inline(described_class.new(related_tags: [row]))

    expect(page).to have_css(
      "[data-role=related-tags] h3",
      text: "Related tags"
    )
  end

  it "renders a pill link for each related tag" do
    gallery = build_stubbed(:gallery)
    tag_a = build_stubbed(:galleries_tag, gallery:, name: "Alpha")
    tag_b = build_stubbed(:galleries_tag, gallery:, name: "Beta")
    rows = [
      Galleries::RelatedTagsQuery::Result.new(
        tag: tag_a, shared_count: 4
      ),
      Galleries::RelatedTagsQuery::Result.new(
        tag: tag_b, shared_count: 1
      )
    ]

    render_inline(described_class.new(related_tags: rows))

    expect(page).to have_link(
      tag_a.display_name,
      href: gallery_tag_path(gallery, tag_a)
    )
    expect(page).to have_link(
      tag_b.display_name,
      href: gallery_tag_path(gallery, tag_b)
    )
  end

  it "renders the shared_count next to each pill" do
    gallery = build_stubbed(:gallery)
    tag = build_stubbed(:galleries_tag, gallery:, name: "Nature")
    row = Galleries::RelatedTagsQuery::Result.new(
      tag:,
      shared_count: 7
    )

    render_inline(described_class.new(related_tags: [row]))

    expect(page).to have_css(
      "[data-role=related-tag-count]",
      text: "(7)"
    )
  end
end
