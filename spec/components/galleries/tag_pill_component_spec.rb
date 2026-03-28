require "rails_helper"

RSpec.describe Galleries::TagPillComponent, type: :component do
  it "renders the tag's display name" do
    tag = build_stubbed(:galleries_tag, name: "Nature")
    render_inline(described_class.new(tag:))

    expect(page).to have_text(tag.display_name)
  end

  it "renders with gray styling for none classification" do
    tag = build_stubbed(:galleries_tag)
    render_inline(described_class.new(tag:))

    expect(page).to have_css(
      "span.bg-gray-100.text-gray-800"
    )
  end

  it "renders with purple styling for subject classification" do
    tag = build_stubbed(
      :galleries_tag,
      classification: :subject
    )
    render_inline(described_class.new(tag:))

    expect(page).to have_css(
      "span.bg-purple-100.text-purple-800"
    )
  end

  it "renders actions inside the pill after the display name" do
    tag = build_stubbed(:galleries_tag, name: "Nature")
    component = described_class.new(tag:)
    render_inline(component) do |c|
      c.with_action { "<button>×</button>".html_safe }
    end

    expect(page).to have_css("span", text: tag.display_name)
    expect(page).to have_button("×")
  end

  it "links the display name when link_url is provided" do
    tag = build_stubbed(:galleries_tag, name: "Nature")
    render_inline(described_class.new(tag:, link_url: "/tags/1"))

    expect(page).to have_link(tag.display_name, href: "/tags/1")
  end


  it "does not link the display name when link_url is absent" do
    tag = build_stubbed(:galleries_tag, name: "Nature")
    render_inline(described_class.new(tag:))

    expect(page).not_to have_link(tag.display_name)
  end
end
