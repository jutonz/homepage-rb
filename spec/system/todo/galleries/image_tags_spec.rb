require "rails_helper"

RSpec.describe "Gallery image tags", type: :system do
  it "can add and remove a tag from an image", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    tag = create(:galleries_tag, gallery:)
    login_as(user)

    visit(gallery_image_path(gallery, image))

    click_on("Search")
    within("turbo-frame#tag-search-result-#{tag.id}") do
      click_on("Add tag")
    end

    within("turbo-frame#tag_#{tag.id}", text: tag.name) do
      expect(image.reload.tags).to include(tag)
      accept_confirm do
        click_on("Remove")
      end
    end

    expect(page).not_to have_css("turbo-frame#tag_#{tag.id}")
    expect(image.reload.tags).to be_empty
  end
end
