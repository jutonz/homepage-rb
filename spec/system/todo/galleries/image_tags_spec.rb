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
    within("[data-role=tag-search-result]", text: tag.name) do
      click_on("Add tag")
    end
    expect(page).not_to have_css(
      "[data-role=tag-search-result]",
      text: tag.name
    )

    within("turbo-frame#tag_#{tag.id}", text: tag.name) do
      expect(image.reload.tags).to include(tag)
      accept_confirm do
        click_on("Remove")
      end
    end

    expect(page).not_to have_css("turbo-frame#tag_#{tag.id}")
    expect(image.reload.tags).to be_empty
  end

  it "clears the search input when adding a tag", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    tag1 = create(:galleries_tag, gallery:, name: "testing 1")
    tag2 = create(:galleries_tag, gallery:, name: "testing 2")
    login_as(user)

    visit(gallery_image_path(gallery, image))

    fill_in("Tag search query", with: "testing")
    click_on("Search")

    within("[data-role=tag-search-result]", text: tag1.name) do
      click_on("Add tag")
    end
    expect(page).to have_field("Tag search query", with: "")

    expect(page).to have_css(
      "[data-role=tag-search-result]",
      text: tag2.name
    )
  end

  it "automatically submits search form", :js do
    user = create(:user)
    gallery = create(:gallery, user:)
    image = create(:galleries_image, gallery:)
    tag = create(:galleries_tag, gallery:)
    login_as(user)

    visit(gallery_image_path(gallery, image))

    fill_in("Tag search query", with: tag.name)

    expect(page).to have_css("[data-role=tag-search-result]", text: tag.name)
  end
end
