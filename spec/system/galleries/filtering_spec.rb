require "rails_helper"

RSpec.describe "Gallery filtering" do
  it "allows filtering and unfiltering by a tag", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    tag = create(:galleries_tag, gallery:)
    image.add_tag(tag)
    login_as(user)

    visit(gallery_path(gallery, image))

    fill_in("Tag search query", with: tag.name)
    click_on("Search")
    within("[data-role=gallery-tag-search-result]", text: tag.name) do
      click_on("Add")
    end

    expect(page).not_to have_css(
      "[data-role=gallery-tag-search-result]",
      text: tag.name
    )
    expect(page).not_to have_css("[data-image-id='#{image.id}]")

    find("[data-role=tag-filter-remove-button]", text: tag.name).click
    expect(page).not_to have_css("[data-image-id='#{image.id}]")
  end
end
