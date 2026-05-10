require "rails_helper"

RSpec.describe Galleries::ImageTagSearchComponent, type: :component do
  it "renders" do
    tag_search = build_stubbed(:galleries_tag_search, :with_image)
    component = described_class.new(tag_search:)
    render_inline(component)

    expect(page).to have_css("h3", text: "Add tag")
    expect(page).to have_css(
      "[data-controller=tag-search]"
    )
  end

  it "renders a lazy turbo-frame pointing at the recent_tags endpoint" do
    tag_search = build_stubbed(:galleries_tag_search, :with_image)
    component = described_class.new(tag_search:)

    render_inline(component)

    expected_src = Rails.application.routes.url_helpers
      .gallery_image_recent_tags_path(tag_search.gallery, tag_search.image)
    expect(page).to have_css(
      "turbo-frame#image-recent-tags" \
      "[src='#{expected_src}']" \
      "[loading='lazy']" \
      "[data-controller~='refresh-on-visible']"
    )
    expect(page).to have_no_css("h4", text: "Recently used tags")
  end
end
