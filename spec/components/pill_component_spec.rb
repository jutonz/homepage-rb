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

  it "renders text with purple color" do
    component = described_class.new(
      text: "subject",
      color: :purple
    )
    render_inline(component)

    expect(page).to have_css(
      "span.bg-purple-100.text-purple-800",
      text: "subject"
    )
  end

  it "renders text with gray color" do
    component = described_class.new(text: "neutral", color: :gray)
    render_inline(component)

    expect(page).to have_css(
      "span.bg-gray-100.text-gray-800",
      text: "neutral"
    )
  end

  it "raises error for unsupported color" do
    expect {
      described_class.new(text: "unknown", color: :asdf)
    }.to raise_error(KeyError, "key not found: :asdf")
  end

  it "renders actions inside the pill after the text" do
    component = described_class.new(text: "hello")
    render_inline(component) do |c|
      c.with_action { "<span>X</span>".html_safe }
    end

    expect(page).to have_css("span", text: "hello")
    expect(page).to have_css("span span", text: "X")
  end
end
