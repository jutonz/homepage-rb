require "rails_helper"

RSpec.describe Galleries::TagCardComponent, type: :component do
  it "links to the tag page and shows the name" do
    tag = build_stubbed(:galleries_tag, name: "Nature")
    render_inline(described_class.new(tag:))

    expect(page).to have_css(
      "a[data-role=tag][href='#{gallery_tag_path(tag.gallery, tag)}']",
      text: "Nature"
    )
  end

  it "shows the image tags count" do
    tag = build_stubbed(:galleries_tag, image_tags_count: 5)
    render_inline(described_class.new(tag:))

    expect(page).to have_text("5")
  end

  it "uses gray styling for none classification" do
    tag = build_stubbed(:galleries_tag)
    render_inline(described_class.new(tag:))

    expect(page).to have_css("a[data-role=tag].border-gray-200")
  end

  it "tints the background purple for subject classification" do
    tag = build_stubbed(:galleries_tag, classification: :subject)
    render_inline(described_class.new(tag:))

    expect(page).to have_css("a[data-role=tag].bg-purple-50")
  end

  it "tints the background red for system classification" do
    tag = build_stubbed(:galleries_tag, classification: :system)
    render_inline(described_class.new(tag:))

    expect(page).to have_css("a[data-role=tag].bg-red-50")
  end

  it "tints the background teal for artist classification" do
    tag = build_stubbed(:galleries_tag, classification: :artist)
    render_inline(described_class.new(tag:))

    expect(page).to have_css("a[data-role=tag].bg-teal-50")
  end

  it "renders the classification pill for classified tags" do
    tag = build_stubbed(:galleries_tag, classification: :subject)
    render_inline(described_class.new(tag:))

    expect(page).to have_text("subject")
  end
end
