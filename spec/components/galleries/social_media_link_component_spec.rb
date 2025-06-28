require "rails_helper"

RSpec.describe Galleries::SocialMediaLinkComponent, type: :component do
  include Rails.application.routes.url_helpers

  it "for url link, renders a link to the url" do
    link = create(:galleries_social_media_link, :url)

    component = described_class.new(link:)
    render_inline(component)

    expect(page).to have_link(link.username)
  end

  it "has a link to edit" do
    link = create(:galleries_social_media_link, :url)
    gallery = link.gallery
    tag = link.tag

    component = described_class.new(link:)
    render_inline(component)

    expect(page).to have_link("Edit") do |el|
      expect(el.native["href"]).to eql(
        edit_gallery_tag_social_media_link_path(gallery, tag, link)
      )
    end
  end
end
