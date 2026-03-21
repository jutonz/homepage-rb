require "rails_helper"

RSpec.describe Galleries::TagPillComponent, type: :component do
  it "renders the tag's display name" do
    tag = build_stubbed(:galleries_tag, name: "Nature")
    render_inline(described_class.new(tag:))

    expect(page).to have_text(tag.display_name)
  end

  it "renders with gray styling" do
    tag = build_stubbed(:galleries_tag)
    render_inline(described_class.new(tag:))

    expect(page).to have_css(
      "span.bg-gray-100.text-gray-800"
    )
  end
end
