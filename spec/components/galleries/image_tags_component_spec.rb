require "rails_helper"

RSpec.describe Galleries::ImageTagsComponent, type: :component do
  include Rails.application.routes.url_helpers

  it "renders tags ordered by name" do
    gallery = create(:gallery)
    image = create(:galleries_image, gallery:)
    tag_b = create(:galleries_tag, gallery:, name: "Tag B")
    tag_a = create(:galleries_tag, gallery:, name: "Tag A")
    [tag_a, tag_b].each { image.add_tag(it) }
    component = described_class.new(image:)
    render_inline(component)

    expect(page).to have_css("[data-role=tags]")
    tags = page.all("[data-role=tag]")
    expect(tags.first.text).to include(tag_a.reload.display_name)
    expect(tags.last.text).to include(tag_b.reload.display_name)
  end

  it "renders a link to the tag" do
    gallery = create(:gallery)
    image = create(:galleries_image, gallery:)
    tag = create(:galleries_tag, gallery:)
    image.add_tag(tag)
    component = described_class.new(image:)
    render_inline(component)

    expect(page).to have_link(
      tag.reload.display_name,
      href: gallery_tag_path(gallery, tag)
    )
  end
end
