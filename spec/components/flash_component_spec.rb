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
end
