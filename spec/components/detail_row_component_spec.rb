require "rails_helper"

RSpec.describe DetailRowComponent, type: :component do
  it "renders the label and value in a justify-between row" do
    component = described_class.new(label: "Group Name", value: "Cool Group")

    render_inline(component)

    expect(page).to have_css(
      "div.flex.justify-between span.font-medium.text-gray-700",
      text: "Group Name:"
    )
    expect(page).to have_css(
      "div.flex.justify-between span",
      text: "Cool Group"
    )
  end

  it "omits the class attribute on the value by default" do
    component = described_class.new(label: "Invited by", value: "a@b.com")

    render_inline(component)

    expect(page).to have_css("span:not([class])", text: "a@b.com")
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

  it "escapes html in the value" do
    component = described_class.new(
      label: "Group Name",
      value: "<script>alert(1)</script>"
    )

    render_inline(component)

    expect(rendered_content).to include("&lt;script&gt;")
    expect(rendered_content).not_to include("<script>")
  end

  it "renders block content as the value when given" do
    component = described_class.new(label: "Members")

    render_inline(component) { "42" }

    expect(page).to have_css("span", text: "42")
  end
end
