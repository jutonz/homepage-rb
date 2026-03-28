require "rails_helper"

RSpec.describe Galleries::TagClassificationPillComponent,
  type: :component do
  it "renders nothing for none classification" do
    tag = build_stubbed(:galleries_tag)
    render_inline(described_class.new(tag:))

    expect(page.text).to be_blank
  end

  it "renders a purple pill for subject classification" do
    tag = build_stubbed(
      :galleries_tag,
      classification: :subject
    )
    render_inline(described_class.new(tag:))

    expect(page).to have_css(
      "span.bg-purple-100.text-purple-800",
      text: "subject"
    )
  end

  it "renders a red pill for system classification" do
    tag = build_stubbed(
      :galleries_tag,
      classification: :system
    )
    render_inline(described_class.new(tag:))

    expect(page).to have_css(
      "span.bg-red-100.text-red-800",
      text: "system"
    )
  end

  it "renders a teal pill for artist classification" do
    tag = build_stubbed(
      :galleries_tag,
      classification: :artist
    )
    render_inline(described_class.new(tag:))

    expect(page).to have_css(
      "span.bg-teal-100.text-teal-800",
      text: "artist"
    )
  end
end
