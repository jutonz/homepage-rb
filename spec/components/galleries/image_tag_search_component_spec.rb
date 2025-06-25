require "rails_helper"

RSpec.describe Galleries::ImageTagSearchComponent, type: :component do
  it "renders" do
    tag_search = build_stubbed(:galleries_tag_search, :with_image)
    component = described_class.new(tag_search:)
    render_inline(component)

    expect(page).to have_css("h3", text: "Add tag")
  end
end
