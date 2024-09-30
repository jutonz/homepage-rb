require "rails_helper"

RSpec.describe HeaderComponent, type: :component do
  it "renders a title" do
    component = described_class.new(title: "hello")
    render_inline(component)

    expect(page).to have_css("h1", text: "hello")
  end

  it "renders actions" do
    component = described_class.new(title: "hello").tap do |c|
      c.with_action { "action1" }
      c.with_action { "action2" }
    end
    render_inline(component)

    expect(page).to have_text("action1")
    expect(page).to have_text("action2")
  end
end
