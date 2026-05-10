require "rails_helper"

RSpec.describe Galleries::Images::RecentTagsComponent, type: :component do
  it "renders a button for each recently used tag" do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    other_image = create(:galleries_image, gallery:)
    tag = create(:galleries_tag, gallery:, name: "rose")
    other_image.add_tag(tag)

    render_inline(described_class.new(gallery:, image:))

    expect(page).to have_css("h4", text: "Recently used tags")
    expect(page).to have_button(tag.reload.display_name)
  end

  it "excludes tags that are already on the current image" do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    tag = create(:galleries_tag, gallery:, name: "tulip")
    image.add_tag(tag)

    render_inline(described_class.new(gallery:, image:))

    expect(page).to have_no_button(tag.reload.display_name)
  end

  it "groups tags by image with separators" do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    image1, image2 = create_pair(:galleries_image, gallery:)
    tag1, tag2 = create_pair(:galleries_tag, gallery:)
    tag3 = create(:galleries_tag, gallery:)
    image1.add_tag(tag1)
    image1.add_tag(tag2)
    image2.add_tag(tag3)

    render_inline(described_class.new(gallery:, image:))

    expect(page).to have_css("[data-testid='tag-group-separator']", count: 1)
    expect(page).to have_text(tag1.reload.display_name)
    expect(page).to have_text(tag2.reload.display_name)
    expect(page).to have_text(tag3.reload.display_name)
  end
end
