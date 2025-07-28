require "rails_helper"

RSpec.describe CardComponent, type: :component do
  it "renders a card with title only" do
    component = described_class.new(title: "Test Card")

    render_inline(component) do
      "Card content"
    end

    expect(page).to have_text("Test Card")
    expect(page).to have_text("Card content")
  end

  it "renders a card with single action" do
    component = described_class.new(title: "Test Card")

    render_inline(component) do |c|
      c.with_action { "Action Button" }
      "Card content"
    end

    expect(page).to have_text("Test Card")
    expect(page).to have_text("Action Button")
    expect(page).to have_text("Card content")
  end

  it "renders a card with multiple actions" do
    component = described_class.new(title: "Test Card")

    render_inline(component) do |c|
      c.with_action { "First Action" }
      c.with_action { "Second Action" }
      "Card content"
    end

    expect(page).to have_text("Test Card")
    expect(page).to have_text("First Action")
    expect(page).to have_text("Second Action")
    expect(page).to have_text("Card content")
  end

  it "renders card without actions when none provided" do
    component = described_class.new(title: "Simple Card")

    render_inline(component) do
      "Just content"
    end

    expect(page).to have_text("Simple Card")
    expect(page).to have_text("Just content")
  end
end
