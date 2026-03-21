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
end
