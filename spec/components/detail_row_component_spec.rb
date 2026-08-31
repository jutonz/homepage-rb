require "rails_helper"

RSpec.describe DetailRowComponent, type: :component do
  it "renders the label and value in a justify-between row" do
    component = described_class.new(label: "Group Name", value: "Cool Group")

    render_inline(component)

    expect(page).to have_css(
      "div.flex.justify-between span.font-medium.text-gray-700",
      text: "Group Name:"
    )
    expect(page).to have_css("div.flex.justify-between span", text: "Cool Group")
  end

  it "renders the value without extra classes by default" do
    component = described_class.new(label: "Invited by", value: "a@b.com")

    render_inline(component)

    expect(page).to have_css('span[class=""]', text: "a@b.com")
  end

  it "applies value_class to the value span" do
    component = described_class.new(
      label: "Expired on",
      value: "June 15, 2023",
      value_class: "text-red-600 font-medium"
    )

    render_inline(component)

    expect(page).to have_css(
      "span.text-red-600.font-medium",
      text: "June 15, 2023"
    )
  end

  it "renders block content as the value when given" do
    component = described_class.new(label: "Members")

    render_inline(component) { "42" }

    expect(page).to have_css("span", text: "42")
  end
end
