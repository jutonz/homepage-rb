require "rails_helper"

RSpec.describe FlashComponent, type: :component do
  it "renders a message and type" do
    component = described_class.new(message: "hi", type: "notice")
    render_inline(component)

    expect(page).to have_css(
      "[data-role=flash][data-flash-type=notice]",
      text: "hi"
    )
  end

  it "applies sky border and bg for notice type" do
    component = described_class.new(message: "Info", type: "notice")
    render_inline(component)

    expect(page).to have_css(
      ".border-sky-500.bg-sky-50",
      text: "Info"
    )
  end

  it "applies emerald border and bg for success type" do
    component = described_class.new(message: "Success!", type: "success")
    render_inline(component)

    expect(page).to have_css(
      ".border-emerald-500.bg-emerald-50",
      text: "Success!"
    )
  end

  it "applies rose border and bg for error type" do
    component = described_class.new(message: "Error!", type: "error")
    render_inline(component)

    expect(page).to have_css(
      ".border-rose-500.bg-rose-50",
      text: "Error!"
    )
  end

  it "applies rose border and bg for alert type" do
    component = described_class.new(message: "Alert!", type: "alert")
    render_inline(component)

    expect(page).to have_css(
      ".border-rose-500.bg-rose-50",
      text: "Alert!"
    )
  end

  it "applies amber border and bg for warning type" do
    component = described_class.new(message: "Warning!", type: "warning")
    render_inline(component)

    expect(page).to have_css(
      ".border-amber-500.bg-amber-50",
      text: "Warning!"
    )
  end
end
