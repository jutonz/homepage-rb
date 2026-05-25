require "rails_helper"

RSpec.describe Galleries::TagSearches::RelatedTagsBoxComponent,
  type: :component do
  it "renders a box header naming the source tag" do
    tag = build_stubbed(:galleries_tag, name: "forest")
    image = build_stubbed(:galleries_image, gallery: tag.gallery)
    component = described_class.new(tag:, image:, related_tags: [])

    render_inline(component)

    expect(page).to have_css("[data-role=related-tags-box]")
    expect(page).to have_text("Related to \"forest\"")
  end

  it "renders a dismiss button wired to the stimulus controller" do
    tag = build_stubbed(:galleries_tag)
    image = build_stubbed(:galleries_image, gallery: tag.gallery)
    component = described_class.new(tag:, image:, related_tags: [])

    render_inline(component)

    expect(page).to have_css(
      "[data-controller=related-tags-box] " \
      "button[data-action='related-tags-box#dismiss']"
    )
  end

  it "renders a row per related tag with shared count and add button" do
    gallery = create(:gallery)
    tag = create(:galleries_tag, gallery:)
    image = create(:galleries_image, gallery:)
    related = create(:galleries_tag, gallery:, name: "beach")
    result = Galleries::RelatedTagsQuery::Result.new(
      tag: related,
      shared_count: 3
    )
    component = described_class.new(tag:, image:, related_tags: [result])

    render_inline(component)

    add_path = gallery_image_tags_path(
      gallery, image, tag_id: related.id, from_related: true
    )
    row = page.find("#related-suggestion-#{related.id}")
    within(row) do
      expect(page).to have_text("3 shared")
      expect(page).to have_selector("form[action='#{add_path}']")
      expect(page).to have_button("Add tag")
    end
  end

  it "does not mark rows as tag-search-result" do
    gallery = create(:gallery)
    tag = create(:galleries_tag, gallery:)
    image = create(:galleries_image, gallery:)
    related = create(:galleries_tag, gallery:)
    result = Galleries::RelatedTagsQuery::Result.new(
      tag: related, shared_count: 1
    )
    component = described_class.new(tag:, image:, related_tags: [result])

    render_inline(component)

    expect(page).to have_no_css("[data-role=tag-search-result]")
  end
end
