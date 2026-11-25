require "rails_helper"

RSpec.describe CopyButtonComponent, type: :component do
  it "renders a small grey Copy button wired to the copy controller" do
    render_inline(described_class.new(value: "jutonz/INFRA-3"))

    expect(page).to have_css(
      "button[type=button].button.button--small.button--secondary" \
      "[data-controller=copy][data-action='copy#copy']",
      text: "Copy",
      exact_text: true
    )
  end

  it "passes the value and reset delay to the controller" do
    render_inline(described_class.new(value: "jutonz/INFRA-3"))

    expect(page).to have_css(
      "button[data-copy-value-value='jutonz/INFRA-3']" \
      "[data-copy-delay-value='2000']"
    )
  end

  it "renders whatever value it is given and nothing else" do
    render_inline(described_class.new(value: "any text"))

    expect(page).to have_css("button[data-copy-value-value='any text']")
    expect(page.text.squish).to eq("Copy")
  end
end
