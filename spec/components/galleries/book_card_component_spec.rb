require "rails_helper"

RSpec.describe Galleries::BookCardComponent, type: :component do
  it "renders book name" do
    book = build_stubbed(:galleries_book, name: "My Book")
    render_inline(described_class.new(book:))

    expect(page).to have_text("My Book")
  end

  it "links to book show page" do
    book = build_stubbed(:galleries_book, name: "Test Book")
    render_inline(described_class.new(book:))

    expect(page).to have_link("Test Book")
  end

  it "has data-role attribute for testing" do
    book = build_stubbed(:galleries_book)
    render_inline(described_class.new(book:))

    expect(page).to have_css('[data-role="book"]')
  end
end
