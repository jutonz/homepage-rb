require "rails_helper"

RSpec.describe PillComponent, type: :component do
  it "renders text with default blue color" do
    component = described_class.new(text: "5 items")
    render_inline(component)

    expect(page).to have_css(
      "span.bg-blue-100.text-blue-800",
      text: "5 items"
    )
  end

  it "renders text with green color" do
    component = described_class.new(text: "3 tags", color: :green)
    render_inline(component)

    expect(page).to have_css(
      "span.bg-green-100.text-green-800",
      text: "3 tags"
    )
  end

  it "raises error for unsupported color" do
    expect {
      described_class.new(text: "unknown", color: :purple)
    }.to raise_error(KeyError, "key not found: :purple")
  end

  it "renders text with gray color" do
    component = described_class.new(text: "neutral", color: :gray)
    render_inline(component)

    expect(page).to have_css(
      "span.bg-gray-100.text-gray-800",
      text: "neutral"
    )
  end
end
